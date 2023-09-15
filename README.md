
![CODE QUALITY](https://github.com/daniel-aguilar-garcia/IRISApiTester/blob/main/screenshots/qualitycode.png)

# Project with InterSystems IRIS + Newman to test Apis and get an html report

--------------------

##NEW ENDPOINTS!!

Now you can configure an external repository where the Postman's collection test is stored

-PULL AND RUN:
Pull last version in the repository, pass test and show the report in the browser (Does not require manual actions dragging files):
http://localhost:52773/pull_and_run_tests



-UNIT TESTING / INTEGRATION TEST

New route to unitesting:
http://localhost:52773/run/ClassName/MethodName

With this new route '/run' you can publish any method only adding the ClassName to the url and the MethodName, example:
http://localhost:52773/run/IrisNewman.Example.TestMethods/TestOK

It could be used for integration test too, see an example on example:
localhost:52773/run/IrisNewman.Example.TestMethods/InsertPerson



-CI/CD USEFULL ENDPOINT:

New route to CI/CD:
You can add this endpoint to your workflows to send to Google Chat the result of the test automatly after every commit.
http://localhost:52773/pull_run_and_send_google

It download the last version of your IrisApiTester repository and download the last version of your test collection repository, run the test and send a message to a webhook of Google Chat with the url to the result test report.

In order to use these new improvements, you must complete the required data in the repository.cfg file.

--------------------


How it works:


Add some test to your collection (In this example I'm adding a global test for the collection that checks the header response code)

![ADD_TEST_COLLECTION](https://github.com/daniel-aguilar-garcia/IRISApiTester/blob/main/screenshots/addtest.png)



Export your collection in json format (For try the app you can use the testCollectionExample.json located on the src folder)


Start the docker-compose file and access to the url 
http://localhost:52773/csp/user/index.html



Drop the exported collection and press the "Run test" button

![HOME_PAGE](https://github.com/daniel-aguilar-garcia/IRISApiTester/blob/main/screenshots/home.png)



You'll be automatically redirected to the report page

![REPORT_PAGE](https://github.com/daniel-aguilar-garcia/IRISApiTester/blob/main/screenshots/report.png)



Enjoy!


