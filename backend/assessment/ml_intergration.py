import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
import os
import pickle
from django.conf import settings

class AssessmentMLService:
    """
    ML service for assessment data analysis and recommendations
    """

    @staticmethod
    def analyze_questionnaire(questionnaire):
        """
        Analyze questionnaire results to provide deeper insights and recommendations

        Args:
            questionnaire: AssistQuestionnaire object

        Returns:
            dict with analysis results
        """
        substance_responses = questionnaire.substance_responses.all()

        # Manually count instead of using filter().count() to avoid Djongo SQL issues
        substances_count = sum(1 for response in substance_responses if response.used_in_lifetime)
        high_risk_substances = sum(1 for response in substance_responses if response.risk_level == 'high')
        moderate_risk_substances = sum(1 for response in substance_responses if response.risk_level == 'moderate')
        injected_substances = sum(1 for response in substance_responses if response.injected)

        # Extract features from responses
        features = {
            'overall_risk_level': questionnaire.overall_risk_level,
            'highest_score': questionnaire.highest_score,
            'substances_count': substances_count,
            'high_risk_substances': high_risk_substances,
            'moderate_risk_substances': moderate_risk_substances,
            'injected_substances': injected_substances,
        }

        # Get substance-specific features
        for substance in substance_responses:
            substance_key = substance.substance.name.lower().replace(' ', '_')
            features[f"{substance_key}_score"] = substance.calculated_score
            features[f"{substance_key}_risk"] = substance.risk_level

        # Generate recommendations
        recommendations = AssessmentMLService._generate_recommendations(features)

        # Determine follow-up assessment schedule
        followup_schedule = AssessmentMLService._determine_followup_schedule(features)

        return {
            'features': features,
            'recommendations': recommendations,
            'followup_schedule': followup_schedule
        }

    @staticmethod
    def _generate_recommendations(features):
        """
        Generate recommendations based on assessment data
        """
        recommendations = []

        # General recommendations
        recommendations.append({
            'type': 'general',
            'text': 'Continue with your recovery journey and keep track of your progress'
        })

        # Risk-level specific recommendations
        if features['overall_risk_level'] == 'high':
            recommendations.append({
                'type': 'risk',
                'text': 'Your assessment indicates significant substance use risks. Consider seeking professional support as soon as possible.'
            })
            recommendations.append({
                'type': 'treatment',
                'text': 'Consider discussing medication-assisted treatment options with a healthcare provider.'
            })
        elif features['overall_risk_level'] == 'moderate':
            recommendations.append({
                'type': 'risk',
                'text': 'Your assessment indicates moderate substance use risks. Regular support and monitoring can help prevent further issues.'
            })
            recommendations.append({
                'type': 'support',
                'text': 'Consider joining support groups or counseling to strengthen your recovery.'
            })
        else:  # Low risk
            recommendations.append({
                'type': 'risk',
                'text': 'Your assessment indicates low substance use risks. Focus on maintaining healthy habits.'
            })

        # Substance-specific recommendations
        for substance, score in features.items():
            if '_score' in substance and score > 20:
                substance_name = substance.replace('_score', '').replace('_', ' ').title()
                recommendations.append({
                    'type': 'substance',
                    'text': f'Consider specific strategies to address {substance_name} use, as your score indicates elevated risk.'
                })

        # If injected substances are present
        if features.get('injected_substances', 0) > 0:
            recommendations.append({
                'type': 'health',
                'text': 'Consider being tested for blood-borne viruses like HIV and Hepatitis due to injection history.'
            })

        return recommendations

    @staticmethod
    def _determine_followup_schedule(features):
        """
        Determine when the next assessment should be scheduled
        """
        if features['overall_risk_level'] == 'high':
            return {
                'next_assessment': '2 weeks',
                'reasoning': 'Your current risk level indicates a need for frequent check-ins'
            }
        elif features['overall_risk_level'] == 'moderate':
            return {
                'next_assessment': '1 month',
                'reasoning': 'Regular check-ins will help monitor your progress'
            }
        else:  # Low risk
            return {
                'next_assessment': '3 months',
                'reasoning': 'Your current risk level indicates less frequent assessments may be sufficient'
            }

    @staticmethod
    def predict_treatment_plan(questionnaire, user_data):
        """
        Recommend a treatment plan based on assessment results
        This would use ML models in a real implementation

        Args:
            questionnaire: AssistQuestionnaire object
            user_data: Additional user data

        Returns:
            dict with recommended plan and reasons
        """
        # Get features from questionnaire
        substance_responses = list(questionnaire.substance_responses.all())

        # Extract key features
        risk_level = questionnaire.overall_risk_level
        highest_score = questionnaire.highest_score
        # Use Python filtering instead of Django ORM filtering
        substances_count = sum(1 for response in substance_responses if response.used_in_lifetime)

        # In a real implementation, we would use ML model to predict
        # For now, use rule-based approach
        if risk_level == 'high':
            return {
                'recommended_plan': 'Unbreakable',
                'confidence': 0.85,
                'reasons': [
                    'Comprehensive approach for high-risk cases',
                    'Provides strong structure and support',
                    'Addresses multiple aspects of recovery'
                ]
            }
        elif risk_level == 'moderate':
            if highest_score > 15:
                return {
                    'recommended_plan': 'Resilience',
                    'confidence': 0.75,
                    'reasons': [
                        'Provides disciplined structure for moderate-risk cases',
                        'Helps build mental strength',
                        'Focuses on transforming mindset'
                    ]
                }
            else:
                return {
                    'recommended_plan': 'Strong Everyday',
                    'confidence': 0.78,
                    'reasons': [
                        'Balanced approach for moderate-risk cases',
                        'Focuses on daily consistency',
                        'Builds recovery habits gradually'
                    ]
                }
        else:  # Low risk
            return {
                'recommended_plan': 'Fresh Start',
                'confidence': 0.92,
                'reasons': [
                    'Gentle approach suitable for low-risk cases',
                    'Builds stable foundation for recovery',
                    'Focuses on small, mindful steps'
                ]
            }