from rest_framework.response import Response
from rest_framework.decorators import api_view
import json

with open('data/questionnaire.json', 'r') as file:
    data = json.load(file)

@api_view(['GET'])
def getQuestionnaire(request):
    return Response(data)


@api_view(['GET'])
def getQuestionById(request, questionId): 
    questionsById = {str(q['id']): q for q in data['questionnaire']['questions']}
    
    question = questionsById.get(str(questionId))
    if question:
        return Response({'question': question}, status=200)
    return Response({'error': 'Question not found'}, status=404)