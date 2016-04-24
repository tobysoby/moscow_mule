var moscowMuleApp = angular.module('moscowMuleApp', [
	'ngRoute'
]);

moscowMuleApp.config(['$routeProvider', function($routeProvider) {
	$routeProvider.
	when('/showfeature', {
		templateUrl: 'partials/single_feature.html',
		controller: 'FeaturesCtrl'
	}).
	when('/phones/:phoneId', {
		templateUrl: 'partials/phone-detail.html',
		controller: 'PhoneDetailCtrl'
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
	}
});