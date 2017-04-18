# moscow_mule

## a simple viewer for cucumber tests

**Ever wondered how to show the supposedly "business-readable" cucumber features to your non-technical stakeholder?**

What can you do? moscow_mule lets you view your cucumber features in a browser. You can get a list of all scenarios with a specific tag. And you can do manual test runs. That's if you have scenarios you want to test manually, but where you also want to track the results. It gives you the result in a table that is understood by JIRA.

Technically moscow_mule consists of an api based on ruby's sinatra to parse and make the features available as json. The magic in the browser happens via an angular js-app.

What's it not supposed to be:
* It isn't supposed to run on a server, but on your local machine.
* It isn't supposed to change your feature files. Do that with a proper text editor and a proper VCS.

##Installation
* bundle install
* ruby moscow_mule.rb

##Specific tags
If you tag your scenarios in a specific way, the app is able to recognize this:
* @testplan:xyz - 
* @tester:xyz - 
* @platform:xyz - 
* @image:xyz.png - The app looks for an image with the name xyz.png in <location-of-your-features>/images and shows this image as a screenshot with your scenario.