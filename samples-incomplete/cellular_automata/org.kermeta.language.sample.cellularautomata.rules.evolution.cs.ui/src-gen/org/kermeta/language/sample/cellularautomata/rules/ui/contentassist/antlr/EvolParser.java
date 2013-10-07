/*
* generated by Xtext
*/
package org.kermeta.language.sample.cellularautomata.rules.ui.contentassist.antlr;

import java.util.Collection;
import java.util.Map;
import java.util.HashMap;

import org.antlr.runtime.RecognitionException;
import org.eclipse.xtext.AbstractElement;
import org.eclipse.xtext.ui.editor.contentassist.antlr.AbstractContentAssistParser;
import org.eclipse.xtext.ui.editor.contentassist.antlr.FollowElement;
import org.eclipse.xtext.ui.editor.contentassist.antlr.internal.AbstractInternalContentAssistParser;

import com.google.inject.Inject;

import org.kermeta.language.sample.cellularautomata.rules.services.EvolGrammarAccess;

public class EvolParser extends AbstractContentAssistParser {
	
	@Inject
	private EvolGrammarAccess grammarAccess;
	
	private Map<AbstractElement, String> nameMappings;
	
	@Override
	protected org.kermeta.language.sample.cellularautomata.rules.ui.contentassist.antlr.internal.InternalEvolParser createParser() {
		org.kermeta.language.sample.cellularautomata.rules.ui.contentassist.antlr.internal.InternalEvolParser result = new org.kermeta.language.sample.cellularautomata.rules.ui.contentassist.antlr.internal.InternalEvolParser(null);
		result.setGrammarAccess(grammarAccess);
		return result;
	}
	
	@Override
	protected String getRuleName(AbstractElement element) {
		if (nameMappings == null) {
			nameMappings = new HashMap<AbstractElement, String>() {
				private static final long serialVersionUID = 1L;
				{
					put(grammarAccess.getLiteralsExpressionAccess().getAlternatives(), "rule__LiteralsExpression__Alternatives");
					put(grammarAccess.getConditionalAccess().getAlternatives(), "rule__Conditional__Alternatives");
					put(grammarAccess.getComparisonExpressionAccess().getAlternatives_1_0(), "rule__ComparisonExpression__Alternatives_1_0");
					put(grammarAccess.getAddExpressionAccess().getAlternatives_1_0(), "rule__AddExpression__Alternatives_1_0");
					put(grammarAccess.getMultExpressionAccess().getAlternatives_1_0(), "rule__MultExpression__Alternatives_1_0");
					put(grammarAccess.getUnaryExpressionAccess().getAlternatives(), "rule__UnaryExpression__Alternatives");
					put(grammarAccess.getCellularAutomataAccess().getGroup(), "rule__CellularAutomata__Group__0");
					put(grammarAccess.getRuleAccess().getGroup(), "rule__Rule__Group__0");
					put(grammarAccess.getPopulationRangeAccess().getGroup(), "rule__PopulationRange__Group__0");
					put(grammarAccess.getLiteralsExpressionAccess().getGroup_0(), "rule__LiteralsExpression__Group_0__0");
					put(grammarAccess.getMaxAccess().getGroup(), "rule__Max__Group__0");
					put(grammarAccess.getMinAccess().getGroup(), "rule__Min__Group__0");
					put(grammarAccess.getSumAccess().getGroup(), "rule__Sum__Group__0");
					put(grammarAccess.getSizeAccess().getGroup(), "rule__Size__Group__0");
					put(grammarAccess.getCurrentCellPopulationAccess().getGroup(), "rule__CurrentCellPopulation__Group__0");
					put(grammarAccess.getConditionalAccess().getGroup_1(), "rule__Conditional__Group_1__0");
					put(grammarAccess.getOrExpressionAccess().getGroup(), "rule__OrExpression__Group__0");
					put(grammarAccess.getOrExpressionAccess().getGroup_1(), "rule__OrExpression__Group_1__0");
					put(grammarAccess.getAndExpressionAccess().getGroup(), "rule__AndExpression__Group__0");
					put(grammarAccess.getAndExpressionAccess().getGroup_1(), "rule__AndExpression__Group_1__0");
					put(grammarAccess.getEqualExpressionAccess().getGroup(), "rule__EqualExpression__Group__0");
					put(grammarAccess.getEqualExpressionAccess().getGroup_1(), "rule__EqualExpression__Group_1__0");
					put(grammarAccess.getComparisonExpressionAccess().getGroup(), "rule__ComparisonExpression__Group__0");
					put(grammarAccess.getComparisonExpressionAccess().getGroup_1(), "rule__ComparisonExpression__Group_1__0");
					put(grammarAccess.getComparisonExpressionAccess().getGroup_1_0_0(), "rule__ComparisonExpression__Group_1_0_0__0");
					put(grammarAccess.getComparisonExpressionAccess().getGroup_1_0_1(), "rule__ComparisonExpression__Group_1_0_1__0");
					put(grammarAccess.getAddExpressionAccess().getGroup(), "rule__AddExpression__Group__0");
					put(grammarAccess.getAddExpressionAccess().getGroup_1(), "rule__AddExpression__Group_1__0");
					put(grammarAccess.getAddExpressionAccess().getGroup_1_0_0(), "rule__AddExpression__Group_1_0_0__0");
					put(grammarAccess.getAddExpressionAccess().getGroup_1_0_1(), "rule__AddExpression__Group_1_0_1__0");
					put(grammarAccess.getMultExpressionAccess().getGroup(), "rule__MultExpression__Group__0");
					put(grammarAccess.getMultExpressionAccess().getGroup_1(), "rule__MultExpression__Group_1__0");
					put(grammarAccess.getMultExpressionAccess().getGroup_1_0_0(), "rule__MultExpression__Group_1_0_0__0");
					put(grammarAccess.getMultExpressionAccess().getGroup_1_0_1(), "rule__MultExpression__Group_1_0_1__0");
					put(grammarAccess.getMultExpressionAccess().getGroup_1_0_2(), "rule__MultExpression__Group_1_0_2__0");
					put(grammarAccess.getUnaryExpressionAccess().getGroup_1(), "rule__UnaryExpression__Group_1__0");
					put(grammarAccess.getUnaryExpressionAccess().getGroup_2(), "rule__UnaryExpression__Group_2__0");
					put(grammarAccess.getEIntAccess().getGroup(), "rule__EInt__Group__0");
					put(grammarAccess.getCellularAutomataAccess().getRulesAssignment_1(), "rule__CellularAutomata__RulesAssignment_1");
					put(grammarAccess.getCellularAutomataAccess().getRulesAssignment_2(), "rule__CellularAutomata__RulesAssignment_2");
					put(grammarAccess.getRuleAccess().getFilterAssignment_1(), "rule__Rule__FilterAssignment_1");
					put(grammarAccess.getRuleAccess().getEvaluatedValAssignment_5(), "rule__Rule__EvaluatedValAssignment_5");
					put(grammarAccess.getPopulationRangeAccess().getLowerRangeAssignment_2(), "rule__PopulationRange__LowerRangeAssignment_2");
					put(grammarAccess.getPopulationRangeAccess().getUpperRangeAssignment_4(), "rule__PopulationRange__UpperRangeAssignment_4");
					put(grammarAccess.getMaxAccess().getNeighborsFilterAssignment_2(), "rule__Max__NeighborsFilterAssignment_2");
					put(grammarAccess.getMinAccess().getNeighborsFilterAssignment_2(), "rule__Min__NeighborsFilterAssignment_2");
					put(grammarAccess.getSumAccess().getNeighborsFilterAssignment_2(), "rule__Sum__NeighborsFilterAssignment_2");
					put(grammarAccess.getSizeAccess().getNeighborsFilterAssignment_2(), "rule__Size__NeighborsFilterAssignment_2");
					put(grammarAccess.getConditionalAccess().getConditionAssignment_1_2(), "rule__Conditional__ConditionAssignment_1_2");
					put(grammarAccess.getConditionalAccess().getIfTrueExpressionAssignment_1_4(), "rule__Conditional__IfTrueExpressionAssignment_1_4");
					put(grammarAccess.getConditionalAccess().getIfFalseExpressionAssignment_1_8(), "rule__Conditional__IfFalseExpressionAssignment_1_8");
					put(grammarAccess.getOrExpressionAccess().getRightAssignment_1_2(), "rule__OrExpression__RightAssignment_1_2");
					put(grammarAccess.getAndExpressionAccess().getRightAssignment_1_2(), "rule__AndExpression__RightAssignment_1_2");
					put(grammarAccess.getEqualExpressionAccess().getRightAssignment_1_2(), "rule__EqualExpression__RightAssignment_1_2");
					put(grammarAccess.getComparisonExpressionAccess().getRightAssignment_1_1(), "rule__ComparisonExpression__RightAssignment_1_1");
					put(grammarAccess.getAddExpressionAccess().getRightAssignment_1_1(), "rule__AddExpression__RightAssignment_1_1");
					put(grammarAccess.getMultExpressionAccess().getRightAssignment_1_1(), "rule__MultExpression__RightAssignment_1_1");
					put(grammarAccess.getUnaryExpressionAccess().getTargetAssignment_1_2(), "rule__UnaryExpression__TargetAssignment_1_2");
					put(grammarAccess.getUnaryExpressionAccess().getTargetAssignment_2_2(), "rule__UnaryExpression__TargetAssignment_2_2");
					put(grammarAccess.getIntegerLiteralAccess().getValAssignment(), "rule__IntegerLiteral__ValAssignment");
				}
			};
		}
		return nameMappings.get(element);
	}
	
	@Override
	protected Collection<FollowElement> getFollowElements(AbstractInternalContentAssistParser parser) {
		try {
			org.kermeta.language.sample.cellularautomata.rules.ui.contentassist.antlr.internal.InternalEvolParser typedParser = (org.kermeta.language.sample.cellularautomata.rules.ui.contentassist.antlr.internal.InternalEvolParser) parser;
			typedParser.entryRuleCellularAutomata();
			return typedParser.getFollowElements();
		} catch(RecognitionException ex) {
			throw new RuntimeException(ex);
		}		
	}
	
	@Override
	protected String[] getInitialHiddenTokens() {
		return new String[] { "RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT" };
	}
	
	public EvolGrammarAccess getGrammarAccess() {
		return this.grammarAccess;
	}
	
	public void setGrammarAccess(EvolGrammarAccess grammarAccess) {
		this.grammarAccess = grammarAccess;
	}
}
