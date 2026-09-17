library QuestionnaireResponse

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Patient

define QuestionnaireResponse:
  QuestionnaireResponse {
    "id": id('phq-9-questionnaireresponse'),
    "questionnaire": canonical('http://somewhere.org/fhir/uv/mycontentig/Questionnaire/phq-9-questionnaire'),
    "status": QuestionnaireResponseStatus('completed'),
    "subject": Reference {
      "reference": string('Patient/example')
    },
    "authored": dateTime(@2021-09-13T16:29:00-07:00),
    "item": {
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('LittleInterest'),
        "text": string('Little interest or pleasure in doing things'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6568-5'),
              "display": string('Not at all')
            }
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('FeelingDown'),
        "text": string('Feeling down, depressed, or hopeless'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6569-3'),
              "display": string('Several days')
            }
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('TroubleSleeping'),
        "text": string('Trouble falling or staying asleep'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6569-3'),
              "display": string('Several days')
            }
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('FeelingTired'),
        "text": string('Feeling tired or having little energy'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6569-3'),
              "display": string('Several days')
            }
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('BadAppetite'),
        "text": string('Poor appetite or overeating'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6568-5'),
              "display": string('Not at all')
            }
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('FeelingBadAboutSelf'),
        "text": string('Feeling bad about yourself - or that you are a failure or have let yourself or your family down'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6568-5'),
              "display": string('Not at all')
            }
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('TroubleConcentrating'),
        "text": string('Trouble concentrating on things, such as reading the newspaper or watching television'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6568-5'),
              "display": string('Not at all')
            }
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('MovingSpeaking'),
        "text": string('Moving or speaking so slowly that other people could have noticed. Or the opposite - being so fidgety or restless that you have been moving around a lot more than usual'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6568-5'),
              "display": string('Not at all')
            }
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('TotalScore'),
        "text": string('Total score'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": integer(3)
          }
        }
      },
      FHIR.QuestionnaireResponse.Item {
        "linkId": string('Difficulty'),
        "text": string('If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people'),
        "answer": {
          FHIR.QuestionnaireResponse.Item.Answer {
            "value": Coding {
              "system": uri('http://loinc.org'),
              "code": code('LA6568-5'),
              "display": string('Not at all')
            }
          }
        }
      }
    }
  }


define function id(value System.String):
  id { value: value }

define function canonical(value System.String):
  canonical { value: value }

define function string(value System.String):
  string { value: value }

define function uri(value System.String):
  uri { value: value }

define function code(value System.String):
  code { value: value }

define function integer(value System.Integer):
  integer { value: value }

define function QuestionnaireResponseStatus(value System.String):
  QuestionnaireResponseStatus { value: value }

define function dateTime(value System.DateTime):
  dateTime { value: value }
