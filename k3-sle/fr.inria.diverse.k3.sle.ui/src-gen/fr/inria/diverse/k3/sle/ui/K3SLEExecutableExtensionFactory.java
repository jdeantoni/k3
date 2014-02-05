/*
 * generated by Xtext
 */
package fr.inria.diverse.k3.sle.ui;

import org.eclipse.xtext.ui.guice.AbstractGuiceAwareExecutableExtensionFactory;
import org.osgi.framework.Bundle;

import com.google.inject.Injector;

import fr.inria.diverse.k3.sle.ui.internal.K3SLEActivator;

/**
 * This class was generated. Customizations should only happen in a newly
 * introduced subclass. 
 */
public class K3SLEExecutableExtensionFactory extends AbstractGuiceAwareExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return K3SLEActivator.getInstance().getBundle();
	}
	
	@Override
	protected Injector getInjector() {
		return K3SLEActivator.getInstance().getInjector(K3SLEActivator.FR_INRIA_DIVERSE_K3_SLE_K3SLE);
	}
	
}