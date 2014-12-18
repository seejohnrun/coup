angular.module('coup', {});

angular.module('coup').service('GameService', ['$http', function ($http) {

  'use strict';

  var playerToken = localStorage.coupToken;

  if (!playerToken) {
    playerToken = localStorage.coupToken = prompt('Your name please:', Math.random().toString(36).substring(7));
  }

  var base = 'http://localhost:9292/games/abc/players/' + playerToken;

  return {

    loseCard: function (cardToken) {
      return $http.get(base + '/lose/' + cardToken);
    },

    adjustMoney: function (amount) {
      return $http.get(base + '/adjust_money/' + amount);
    },

    returnCard: function (cardToken) {
      return $http.get(base + '/return/' + cardToken);
    },

    draw: function (amount) {
      return $http.get(base + '/draw?cards=' + amount.toString());
    },

    refresh: function () {
      return $http.get(base);
    }

  };

}]);

angular.module('coup').controller('GameCtrl', ['$scope', '$interval', 'GameService', function ($scope, $interval, GameService) {

  'use strict';

  // Reload game
  $scope.reloadGame = function () {
    GameService.refresh().then(function (response) {
      $scope.game = response.data;
    });
  };

  // Draw two cards for an ambassador swap
  $scope.ambassadorSwapping = false;
  $scope.startSwap = function (amount) {
    $scope.ambassadorSwapping = true;
    GameService.draw(2).then(function (response) {
      $scope.game = response.data;
    });
  };

  // Return a card from the hand
  $scope.returnCard = function (card) {
    if (!$scope.ambassadorSwapping) { return; } // no remove if not swapping
    GameService.returnCard(card.token).then(function (response) {
      $scope.game = response.data;
      if (response.data.hand.cards.length === 2) {
        $scope.ambassadorSwapping = false;
      }
    });
  };

  $scope.loseCard = function (card) {
    GameService.loseCard(card.token).then(function (response) {
      $scope.game = response.data;
    });
  };

  $scope.addMoney = function (amount) {
    GameService.adjustMoney(amount).then(function (response) {
      $scope.game = response.data;
    });
  };

  $scope.canAdd = function (amount) {
    var res = $scope.game.hand.money + amount;
    return res < 0 || res >= 10;
  };

  // BOOTSTRAP
  $scope.game = { hand: { money: 0 } };
  $scope.reloadGame();

  $interval($scope.reloadGame, 3000);

}]);
