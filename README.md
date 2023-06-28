
# Project with InterSystems IRIS + Newman to test Apis and get an html report


How it works:


Add some test to your collection (In this example I'm adding a global test for the collection that checks the header response code)

![ADD_TEST_COLLECTION](https://github.com/daniel-aguilar-garcia/IRISApiTester/blob/main/screenshots/addtest.png)



Export your collection in json format (For try the app you can use the testCollectionExample.json located on the src folder)


Start the docker-compose file and access to the url http://localhost:52773/csp/user/index.html


Drop the exported collection and press the "Run test" button

![HOME_PAGE](https://github.com/daniel-aguilar-garcia/IRISApiTester/blob/main/screenshots/home.png)



You'll be automatically redirected to the report page

![REPORT_PAGE](https://github.com/daniel-aguilar-garcia/IRISApiTester/blob/main/screenshots/report.png)



Enjoy!


