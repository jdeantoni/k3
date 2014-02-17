package fr.inria.diverse.k3.al.annotationprocessor

import java.util.ArrayList
import java.util.Collections
import java.util.Comparator
import java.util.HashMap
import java.util.LinkedHashSet
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(typeof(AspectProcessor)) 
public annotation Aspect {
	Class<?> className;
	Class<?>[] with = #[];
}

public annotation OverrideAspectMethod {
}

public annotation NotAspectProperty {
}

public annotation ReplaceAspectMethod {
}

class sortMethod implements Comparator<MutableMethodDeclaration> {

	TransformationContext context

	new(TransformationContext context) {
		this.context = context
	}

	def override int compare(MutableMethodDeclaration arg0, MutableMethodDeclaration arg2) {
		val ext = new ArrayList<MutableClassDeclaration>()
		getSuperClass(ext, arg0.declaringType as MutableClassDeclaration, context)
		val ext1 = new ArrayList<MutableClassDeclaration>()
		getSuperClass(ext1, arg2.declaringType as MutableClassDeclaration, context)

		if (ext.contains(arg2.declaringType)) {
			//context.addError(arg0.declaringType,arg0.declaringType.simpleName + " > " + arg2.declaringType.simpleName+" " +ext.size)
			return -1
		} else if (ext1.contains(arg0.declaringType)) {
			//context.addError(arg0.declaringType,arg0.declaringType.simpleName + " < " + arg2.declaringType.simpleName + " " +ext1.size)
			return 1
		} else {
			//context.addError(arg0.declaringType,arg0.declaringType.simpleName + " = " + arg2.declaringType.simpleName)
			return 0
		}
	}

	def void getSuperClass(List<MutableClassDeclaration> s, MutableClassDeclaration c, extension TransformationContext context) {
		if (c.extendedClass != null) {
			val l = findClass(c.extendedClass.name)
			if (l != null) {
				s.add(l)
				getSuperClass(s, l, context)
			}
		}
	}
}


public class AspectProcessor extends AbstractClassProcessor implements CodeGenerationParticipant<ClassDeclaration>{
	val annotationName = "className"
	val annotationWith = "with"

	val Map<MutableClassDeclaration,List<MutableClassDeclaration>> listResMap = new HashMap


	private def TypeReference getAnnotationAspectType(TypeDeclaration cl) {
		if(cl==null || cl.annotations==null) return null;
		try{
			val annot = cl.annotations.findFirst[getClassValue(annotationName) != null]
			if(annot==null) return null
			annot.getClassValue(annotationName)
		}catch(NullPointerException ex){ return null }
	}
	
	/**
	 * Getting the classes identified by the parameter 'with'
	 */
	private def List<TypeReference> getAnnotationWithType(TypeDeclaration cl) {
		if(cl==null || cl.annotations==null) return null;
		try{
			val annot = cl.annotations.findFirst[getClassArrayValue(annotationWith) != null]
			if(annot==null) return null
			new ArrayList(annot.getClassArrayValue(annotationWith))
		}catch(NullPointerException ex){ return null }
	}

	/** Computes the name of the class to aspectize identified by the annotation 'aspect'. */
	private def String getAspectedClassName(MutableTypeDeclaration clazz, extension TransformationContext context) {
		val type = getAnnotationAspectType(clazz)
		if(type==null)
			return ""	
		type.name
	}
	
	/** Computes the names of the classes provided by the parameter 'with' of the annotation 'aspect'. */
	private def List<String> getWithClassNames(MutableTypeDeclaration clazz, extension TransformationContext context) {
		val types = getAnnotationWithType(clazz)
		if(types==null)
			return Collections.emptyList	
		types.map[name]
	}
	

	/**
	 * Fill s with super classes of c, ordered by hierarchy
	 * (the first element is the direct super type of c)
	 */
	def void getSuperClass(List<MutableClassDeclaration> s, MutableClassDeclaration c, extension TransformationContext context) {
		if (c.extendedClass != null) {
			val l = findClass(c.extendedClass.name)
			if (l != null) {
				s.add(l)
				getSuperClass(s, l, context)
			}
		} 
	}


	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
		val type = getAnnotationAspectType(annotatedClass)
		if(type!=null) {
			val className = type.simpleName
			context.registerClass(annotatedClass.qualifiedName + className + "AspectProperties")
			context.registerClass(annotatedClass.qualifiedName + className + "AspectContext")
		}
	}


	def List<MutableClassDeclaration> sortByClassInheritance(MutableClassDeclaration clazz, List<? extends MutableClassDeclaration> classes, extension TransformationContext context) {
		val List<MutableClassDeclaration> listTmp = new ArrayList
		val List<MutableClassDeclaration> listRes = new ArrayList
		
		getSuperClasses(clazz, listRes, context)
		
		classes.forEach[c | if (!listRes.contains(c)){ 
			listTmp.clear
			getSuperClasses(c, listTmp, context)
			if (listTmp.contains(clazz))
				listRes.add(c)
		} ]

		val list = listRes.toList
		
		sortClasses(list, context)
//		Collections.sort(list, [a, b | 
//			var int value
//			listTmp.clear
//			getSuperClasses(a, listTmp, context)
//
//			if (listTmp.contains(b)) value = -1 
//			else {
//				listTmp.clear
//				getSuperClasses(b, listTmp, context)
//				listTmp.remove(b)
//				if(listTmp.contains(a)) value = 1 
//				else value = 0
//			}
//			value
//		])
		return list
	}
	
	
	private def void sortClasses(List<MutableClassDeclaration> classes, TransformationContext ctx) {
		if(classes==null || classes.size<2) return;
		val size = classes.size
		var firstPosModif = -1
		var stable = false
		val MutableClassDeclaration[] list = newArrayOfSize(size)
		val List<MutableClassDeclaration> listTmp = new ArrayList
		var MutableClassDeclaration tmp;
		classes.toArray(list)
		
		while(!stable) {
			stable = true
			val start = Math::max(0, firstPosModif)
			firstPosModif = -1
			for(i : start..<size-1){
				listTmp.clear
				getSuperClasses(list.get(i+1), listTmp, ctx)
				if(listTmp.contains(list.get(i))) {
					stable = false
					tmp = list.get(i)
					list.set(i, list.get(i+1))
					list.set(i+1, tmp)
					if(firstPosModif>i-1 || firstPosModif==-1) firstPosModif = Math::max(0, i-1)
				}
				else {
					listTmp.clear
					getSuperClasses(list.get(i), listTmp, ctx)
					if(!listTmp.contains(list.get(i+1))) {
						var sortedOnce = false
						var j = i-1
						listTmp.clear
						getSuperClasses(list.get(i+1), listTmp, ctx)
					
						while(j>=0 && !sortedOnce)
							if(listTmp.contains(list.get(j))) {
								tmp = list.get(j)
								list.set(j, list.get(i+1))
								list.set(i+1, tmp)
								stable = false
								sortedOnce = true
								if(start>j-1 || firstPosModif==-1) firstPosModif = Math::max(0, j-1)
							}
							else j=j-1
					}
				}
			}
		}
		
		classes.clear
		classes.addAll(list.toList)
	}


	/**
	 * Completes the list 'res' with all the super types of the given class 'clazz'.
	 */
	private def void getSuperClasses(MutableClassDeclaration clazz, List<MutableClassDeclaration> res, extension TransformationContext ctx) {
		if(res.contains(clazz)) return;
		res.add(clazz)
		val l = findClass(clazz.extendedClass.name)
		if(l!=null)
			getSuperClasses(l,res,ctx)
		getWithClassNames(clazz, ctx).map[n | findClass(n)].forEach[cl| if(cl!=null) getSuperClasses(cl, res, ctx)]
	}


	private def List<MutableMethodDeclaration> sortByMethodInheritance(Set<MutableMethodDeclaration> methods, List<String> inheritOrder) {
		inheritOrder.map[classe | methods.filter[declaringType.simpleName == classe]].flatten.toList
	}


	override def doTransform(List<? extends MutableClassDeclaration> classes, extension TransformationContext context) {
		//Method name_parameterlengths, 
		val Map<MutableClassDeclaration, List<MutableClassDeclaration>> superclass = new HashMap
		val Map<MutableMethodDeclaration, Set<MutableMethodDeclaration>> dispatchmethod = new HashMap
		init_superclass(classes, context, superclass)
		init_dispatchmethod(superclass, dispatchmethod, context)
		
		for (clazz : classes) {
			val List<MutableClassDeclaration> listRes = sortByClassInheritance(clazz, classes, context)
			val List<String> inheritList = listRes.map[simpleName]
			listResMap.put(clazz,listRes)
			val typeRef = getAnnotationAspectType(clazz)
			if(typeRef==null)
				clazz.addError("The aspectised class cannot be resolved.")
			else {
				val className = typeRef.simpleName
				val identifier = typeRef.name
				val Map<MutableMethodDeclaration, String> bodies = new HashMap
	
				//MOVE non static fields
				fields_processing(context, clazz, className, identifier, bodies)
	
				//Transform method to static
				methods_processing(clazz, context, identifier, bodies, dispatchmethod, inheritList, className)
				aspectContextMaker(context, clazz, className, identifier)
			}
		}
	}


	def methods_processing(MutableClassDeclaration clazz, extension TransformationContext context, String identifier, 
		Map<MutableMethodDeclaration,String> bodies, Map<MutableMethodDeclaration,Set<MutableMethodDeclaration>> dispatchmethod, 
		List<String> inheritList, String className) {
		for (m : clazz.declaredMethods) {
			//clazz.addError(m.simpleName)
			//In not visited method, add _self as first parameter and set it static
			if (m.parameters.size == 0 || (m.parameters.size > 0 && m.parameters.get(0).simpleName != '_self')) {
				val l = new ArrayList<Pair<String, TypeReference>>()
				for (p1 : m.parameters)
					l.add(new Pair(p1.simpleName, p1.type))
				
				m.parameters.toList.clear				
				m.addParameter("_self", newTypeReference(identifier))

				for (param : l)
					m.addParameter(param.key, param.value)
				//m.parameters.add(1,m.parameters.remove(m.parameters.size-1))
			}

				/*/						clazz.addError("Each method must have at least one parameter")
				if ()
					clazz.addError("First parameter must be nammed self")*/
				//if (m.parameters.size > 0 && m.parameters.get(0).type.simpleName != className)
				//	clazz.addError("First parameter must be typed by the aspect "  + m.parameters.get(0).type.simpleName) //MOVE non static fields
				if (!m.static)
					m.setStatic(true)

				//Add a method "super_methodName" which call first method in the
				//super class hierarchy with the same name.
				if (clazz.extendedClass != null && m.annotations.findFirst[a|
					a.annotationTypeDeclaration.simpleName == "OverrideAspectMethod"] != null) {
					clazz.addMethod("super_" + m.simpleName,
						[
							//visibility = Visibility::PRIVATE
							visibility = Visibility::PRIVATE
							static = true
							returnType = m.returnType
							for (p : m.parameters)
								//if (p.simpleName != "self")
								addParameter(p.simpleName, p.type)
							var s = "";
							for (p : m.parameters)
								s = s + p.simpleName + ","
							if (s.length > 0)
								s = s.substring(0, s.length - 1)
							val s1 = s
							
							//clazz.addError(clazz.simpleName)
							//clazz.addError(clazz.extendedClass.name)
							val superClass = findClass(clazz.extendedClass.name)
							if (superClass == null)
								clazz.addError("class " + clazz.simpleName + " has no super class")
							else
							{val m3 = findMethod(superClass, m, context)
							if (m3 == null)
								m.addError("No super method found")
							//TODO find super method
							//val ret = m3.returnType.name
							body = [''' «IF (m3.returnType.name != "void")»return «ENDIF» «m3.declaringType.newTypeReference.name».priv«m.simpleName»(«s1»);  ''']
								
							}
						])
				}

				//Add "_hidden_" at the beginning of the replaced method name
				if (m.annotations.findFirst[a|a.annotationTypeDeclaration.simpleName == "ReplaceAspectMethod"] != null) {
					val cl = findClass(identifier)
					if (cl != null) {
						val m2 = cl.declaredMethods.findFirst[m2|
							m2.simpleName == m.simpleName && m2.parameters.size == m.parameters.size - 1]
						m2.setSimpleName("_hidden_" + m.simpleName)
					}
					//TODO Le faire pour toutes les classes montantes et descendantes

				}

				//Make "priv"+methodName as a copy of the method
				clazz.addMethod("priv" + m.simpleName,
					[
						visibility = Visibility::PROTECTED
						static = true
						abstract = false
						returnType = m.returnType
						if (m.abstract)
							body = ['''throw new java.lang.RuntimeException("Not implemented");''']
						else {
							if (m.body == null) {
								body = [bodies.get(m)] //getters & setters
								//addError(bodies.get(m))
							} else
									body = m.body
						}
						for (p : m.parameters)
							addParameter(p.simpleName, p.type)
					])

				//Change the body of the method to call the closest 
				//method "priv"+methodName in the aspect hierarchy
				var s = "";
				for (p : m.parameters)
					s = s + p.simpleName + ","
				if (s.length > 0)
					s = s.substring(0, s.length - 1)
				val s1 = s
				var ret = ""
				if (m.returnType != newTypeReference("void"))
					ret = "return"
				val retu = ret
				var callt = ""

				if(dispatchmethod.get(m) != null) {
					val listmethod = sortByMethodInheritance(dispatchmethod.get(m), inheritList)
					val declTypes = new ArrayList(listmethod.map[declaringType])
					val size = declTypes.size
					var i=1

					for(type : declTypes) {
						for(pos : i..<size)
							if(type.isAssignableFrom(declTypes.get(pos)))
								addError(clazz, "The generated factory does not have a correct hierarchy: " + type.simpleName + ", " + declTypes.get(pos).simpleName)
						i=i+1
					}

					val ifst = '''«FOR dt : declTypes» if (_self instanceof «getAspectedClassName(dt,context)»){
	«retu» «dt.newTypeReference.name».priv«m.simpleName»(«s1.replaceFirst("_self",
						"(" + getAspectedClassName(dt,context) + ")_self")»);
	} else«ENDFOR»'''
					callt = ifst + ''' { throw new IllegalArgumentException("Unhandled parameter types: " + java.util.Arrays.<Object>asList(_self).toString()); }'''
				}
				else callt = '''«retu» priv«m.simpleName»(«s1»); ''' //for getters & setters

				val call = callt
				m.abstract = false
				m.body = [
					'''«clazz.qualifiedName + className»AspectContext _instance = «clazz.qualifiedName +
						className»AspectContext.getInstance();
				    java.util.Map<«identifier + mkstring(newTypeReference(identifier).actualTypeArguments,",","<",">")»,«clazz.qualifiedName + className»AspectProperties> selfProp = _instance.getMap();
					boolean _containsKey = selfProp.containsKey(_self);
				    boolean _not = (!_containsKey);
				    if (_not) {
  						«clazz.qualifiedName + className»AspectProperties prop = new «clazz.qualifiedName + className»AspectProperties();
				   selfProp.put(_self, prop);
			    }
			     _self_ = selfProp.get(_self);
			     «call»
			    ''']
				}
	}

	/**
	 * Create the class which link classes with their aspects 
	 */
	def aspectContextMaker(extension TransformationContext context, MutableClassDeclaration clazz, String className, String identifier) {
		val holderClass = findClass(clazz.qualifiedName + className + "AspectContext")
		holderClass.visibility = Visibility::PUBLIC
		holderClass.addConstructor [
			visibility = Visibility::PRIVATE
		]

		holderClass.addField('INSTANCE') [
			visibility = Visibility::PUBLIC
			static = true
			final = true
			type = holderClass.newTypeReference
			initializer = [
				'''new «holderClass.simpleName»()'''
			]
		]

		holderClass.addMethod('getInstance') [
			visibility = Visibility::PUBLIC
			static = true
			returnType = holderClass.newTypeReference
			body = [
				'''return INSTANCE;'''
			]
		]

		holderClass.addField('map',
			[
				visibility = Visibility::PRIVATE
				static = false
				type = newTypeReference("java.util.Map", newTypeReference(identifier),
					newTypeReference(clazz.qualifiedName + className + "AspectProperties"))
				initializer = [
					'''new java.util.HashMap<«identifier + mkstring(newTypeReference(identifier).actualTypeArguments,",","<",">")», «clazz.qualifiedName + className»AspectProperties>()''']
			])
 
		holderClass.addMethod('getMap') [
			visibility = Visibility::PUBLIC
			static = false
			returnType = newTypeReference("java.util.Map", newTypeReference(identifier),
				newTypeReference(clazz.qualifiedName + className + "AspectProperties"))
			body = ['''return map;''']
		]
	}

	static def String mkstring(List<TypeReference> list, String delimiter, String before, String after ){
		if (list.size==0)
			return ""
		val s = new StringBuffer
		if (before!= null)
			s.append(before)
		list.forEach[e| s.append(delimiter+"?" )   ]
		
		if (after != null)
			s.append(after)
		return s.toString().replace(before+delimiter, before)
	}
		
	/**
	 * Move fields of the aspect to the AspectProperties class
	 */
	def fields_processing(extension TransformationContext context, MutableClassDeclaration clazz, String className, String identifier, Map<MutableMethodDeclaration,String> bodies) {
		val List<MutableFieldDeclaration> toRemove = new ArrayList
		val List<MutableFieldDeclaration> propertyAspect = new ArrayList
		val c = findClass(clazz.qualifiedName + className + "AspectProperties")
		
		for (f : clazz.declaredFields) {
			//MOVE non static fields
			if (/*!f.static &&*/f.simpleName != "_self_") {
				toRemove.add(f)
				if (f.annotations.findFirst[a|a.annotationTypeDeclaration.simpleName == "NotAspectProperty"] == null)
					propertyAspect.add(f)

				c.addField(f.simpleName) [
					visibility = Visibility::PUBLIC
					static = f.static
					final = f.final
					type = f.type
					if (f.initializer != null) {
						initializer = f.initializer
					}
				]

			} else if (!f.static && f.simpleName == "_self_") {
				f.type = findClass(clazz.qualifiedName + className + "AspectProperties").newTypeReference()
				f.static = true
			}

		}
		var selfVar = clazz.declaredFields.findFirst[simpleName == "_self_"]
		if (selfVar == null) {
			clazz.addField("_self_",
				[
					type = findClass(clazz.qualifiedName + className + "AspectProperties").newTypeReference()
					static = true
					visibility = Visibility::PUBLIC
				])
		}

		//Create getters and setters
		for (f : propertyAspect) {
			var get = clazz.addMethod(f.simpleName,
				[
					returnType = f.type
					addParameter("_self", newTypeReference(identifier))
				])
			bodies.put(get, ''' return «clazz.qualifiedName»._self_.«f.simpleName»; ''')

			if(!f.final) {
				var set = clazz.addMethod(f.simpleName,
					[
						returnType = newTypeReference("void")
						addParameter("_self", newTypeReference(identifier))
						addParameter(f.simpleName, f.type)
					])
				bodies.put(set, '''«clazz.qualifiedName»._self_.«f.simpleName» = «f.simpleName»; ''')
			}

		}
		for (f : toRemove)
			f.remove
	}

	/**
	 * Each aspect method is associatated with the lists of all methods with the
	 * same signature (name + number of args) of parents classes and children classes.
	 * 
	 * @superclass All aspects associated with their superclasses
	 * @dispatchmethod Associations computed
	 * @context
	 */
	def init_dispatchmethod(Map<MutableClassDeclaration,List<MutableClassDeclaration>> superclass, Map<MutableMethodDeclaration,Set<MutableMethodDeclaration>> dispatchmethod, TransformationContext context) {
		var i =0
		for (cl : superclass.keySet) {
			//Regroup methods of the class hierarchy by name+number of parameters
			val clazzes = new ArrayList<MutableClassDeclaration>()
			clazzes.add(cl)
			clazzes.addAll(superclass.get(cl))
			val Map<String, Set<MutableMethodDeclaration>> dispatchs = new HashMap
			for (clazz : clazzes) {
				for (m : clazz.declaredMethods) {
					val mname = m.simpleName + "__" + m.parameters.size
					var v = dispatchs.get(mname)
					if (v == null) {
						v = new LinkedHashSet<MutableMethodDeclaration>()
						dispatchs.put(mname, v)
					}
					v.add(m)
				}
			}
			
			for (key : dispatchs.keySet) {
				val res = dispatchs.get(key)
				if (res.size > 1) {
					i=i+res.size
					for (m : res) {
						if (dispatchmethod.get(m) == null)
							dispatchmethod.put(m, res)
						else
							dispatchmethod.get(m).addAll(res)
					}
				}
			}
		}

		//Sort Dispatchmethod entries values by hierarchy of their containing classes
		for (m : dispatchmethod.keySet) {
			val l = dispatchmethod.get(m).sort(new sortMethod(context))
			dispatchmethod.get(m).clear
			dispatchmethod.get(m).addAll(l)
			//m.addError(dispatchmethod.get(m).size.toString)
		}
	}
	
	/**
	 * For each annotated class store his super classes hierarchy.
	 * An annotated class which is a parent of an other annotated
	 * class is not in the final result.
	 * 
	 * @annotedClasses All aspects
	 * @superclass Mapping computed between class and list of his super classes
	 * @context
	 */
	def init_superclass(List<? extends MutableClassDeclaration> annotedClasses, TransformationContext context, Map<MutableClassDeclaration,List<MutableClassDeclaration>> superclass) {
		//Add super classes for all annotated classes
		for (clazz : annotedClasses) {
			val ext = new ArrayList<MutableClassDeclaration>()
			getSuperClass(ext, clazz, context)
			if (ext.size > 0)
				superclass.put(clazz, ext)
		}
		//Get all super classes
		val allparent = new LinkedHashSet<MutableClassDeclaration>()
		for (child : superclass.keySet) {
			allparent.addAll(superclass.get(child))
		}
		//Remove super classes which are annotated
		for (p : allparent)
			superclass.remove(p)
	}

	
	/**
	 * Find first method with the same name in super classes hierarchy
	 * 
	 * @clazz This class and super classes are the search area
	 * @methodName Method to find
	 */
	def MutableMethodDeclaration findMethod(MutableClassDeclaration clazz,
		MutableMethodDeclaration methodName, extension TransformationContext context) {

		//FIXME: take care about number of parameters ? 
		var m = clazz.declaredMethods.findFirst[m2|m2.simpleName == methodName.simpleName]
		if (m == null) {
			if (clazz.extendedClass == null)
				return null
			else if (findClass(clazz.extendedClass.name) == null)
				return null
			else
				return findMethod(findClass(clazz.extendedClass.name), methodName, context)
		} else
			return m;
	}
	
	
	/**
	 * use an additional code generator to produce the .k3_aspect_mapping.properties file
	 */
	override doGenerateCode(List<? extends ClassDeclaration> annotatedSourceElements, extension CodeGenerationContext context) {
		// clean up previous version
		if(annotatedSourceElements.size > 0){
			val filePath = annotatedSourceElements.get(0).compilationUnit.filePath
			filePath.projectFolder.lastSegment
			val file = filePath.projectFolder.append("/META-INF/xtend-gen/"+filePath.projectFolder.lastSegment + ".k3_aspect_mapping.properties")
			file.delete
		}
		// add aspectizedClass = aspectClass mapping
		for (clazz : annotatedSourceElements) {
			
			val filePath = clazz.compilationUnit.filePath
			filePath.projectFolder.lastSegment
			val file = filePath.projectFolder.append("/META-INF/xtend-gen/"+filePath.projectFolder.lastSegment + ".k3_aspect_mapping.properties")
			val aspectizedclassNam = getAnnotationAspectType(clazz)

			if(aspectizedclassNam!=null) {
				val aspectizedclassName = aspectizedclassNam.class.getMethod("getQualifiedName").invoke(aspectizedclassNam) as String
					
				if(file.exists){
					file.contents = '''«file.contents»
	«aspectizedclassName» = «clazz.qualifiedName»
				'''
				}
				else{
				file.contents = '''
	«aspectizedclassName» = «clazz.qualifiedName»
				'''
				}
			}
		}
	}
}
		