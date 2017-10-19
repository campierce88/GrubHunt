The layout of my project is setup in the following groups:
- Utils & Extensions for helper classes
- API which is broken into a APIConstants file, a base APIClient class, and API classes for making requests against the Yelp API broken up by logical category
- Models which contains 4 CoreData backed model objects.
- Views which contains all xib files such as custom table and collection view cells
- Controllers which contains the initial launch point (SearchCollectionViewController) and a BusinessDetailsViewController for when click into view further information about the Business Search Result.

Once you do a pod install from the project directory, open my .xcworkspace, build, and run the app you will be presented with a Search Bar to input your query.
Please allow location settings to be able to query the Yelp API.
Enter a search term and press the "Search" or "Find Near Me" buttons to see results.
Doing this will fetch all the businessess matching this search term, and store the results using CoreData.
Now select the business you are interested in to view the details page.
