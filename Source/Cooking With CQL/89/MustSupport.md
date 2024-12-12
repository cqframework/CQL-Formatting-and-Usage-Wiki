# Must Support in Quality Measure IG

For resource instances claiming to conform to Quality Measure IG profiles, Must Support on any profile data element SHALL be interpreted as follows:

* Authoring systems and knowledge repositories SHALL be capable of populating all Must Support data elements.
* Evaluating systems SHALL be capable of processing resource instances containing Must Support data elements without generating an error or causing the evaluation to fail.
* In situations where information on a particular data element is not present and the reason for absence is unknown, authoring and repository systems SHALL NOT include the data elements in the resource instance.
* When consuming resource instances, evaluating systems SHALL interpret missing data elements within resource instances as data not present for the artifact.
* Submitting and receiving systems using Quality Measure artifacts to perform data exchange or artifact evaluation operations SHALL respect the must support requirements of the profiles used by the artifact to describe the data involved in the operation.
