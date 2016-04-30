var moscowMuleApp = angular.module('moscowMuleApp', [
	'ngRoute'
]);

moscowMuleApp.config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/showfeature', {
		templateUrl: 'partials/single_feature.html',
		controller: 'FeaturesCtrl'
	}).
	when('/runtests', {
		templateUrl: 'partials/run_tests.html',
		controller: 'RunTestsCtrl'
	}).
	otherwise({
		redirectTo: '/phones'
	});
}]);

moscowMuleApp.controller('FeaturesCtrl', function($scope, $http){

	$scope.testsToRun = [];

	$http.get('http://localhost:4567/features').then(function(featuresResponse) {
		$scope.features = featuresResponse.data;
	});
	$http.get('http://localhost:4567/scenarios').then(function(featuresResponse) {
		$scope.scenarios = featuresResponse.data;
	});
	$http.get('http://localhost:4567/tags/testers').then(function(featuresResponse) {
		$scope.tags_testers = featuresResponse.data;
	});
	$http.get('http://localhost:4567/tags/testplans').then(function(featuresResponse) {
		$scope.tags_testplans = featuresResponse.data;
	});
	$http.get('http://localhost:4567/tags/platforms').then(function(featuresResponse) {
		$scope.tags_platforms = featuresResponse.data;
	});
	$http.get('http://localhost:4567/tags/global').then(function(featuresResponse) {
		$scope.tags_global = featuresResponse.data;
	});
	$scope.setFeature = function(feature) {
		$scope.currentFeature = feature;
		$scope.scenariosInFeature = [];

		var scenariosInFeatureIds = feature.scenarios;
		for (var i = 0; i<scenariosInFeatureIds.length; i++) {
			var scenarioId = parseInt(scenariosInFeatureIds[i]);
			$scope.scenariosInFeature.push($scope.scenarios[scenarioId]);
		}
	};
	$scope.addToTestRun = function(scenario) {
		//if the scenario is not yet in the scenarios to run array
		if ($scope.$parent.testsToRun.indexOf(scenario) == -1) {
			//add it!
			$scope.$parent.testsToRun.push(scenario);
		}
	};
	$scope.startRunningTests = function() {
		//set the test_index
		$scope.test_index = -1;
		//set the text of the button on the test_page
		$scope.buttonText = "Start running tests";
	};
});

moscowMuleApp.controller('RunTestsCtrl', function($scope){
	$scope.setTest = function() {
		//get the current test_index
		test_index = $scope.test_index;
		//raise the test_index
		test_index += 1;
		//get the scenario which should be tested
		$scope.scenarioToTest = $scope.testsToRun[test_index];
		//set the buttons text
		if (test_index < $scope.testsToRun.length-1) {
			$scope.buttonText = "Next Test";
		}
		else {
			$scope.buttonText = "Show test results";
		}
		//write the test_index into the scope
		$scope.test_index = test_index;
	};
});