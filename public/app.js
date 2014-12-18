angular.module('coup', {});

angular.module('coup').service('GameService', ['$http', function ($http) {

  'use strict';

  var playerToken = localStorage.coupToken;
  if (playerToken === 'null') { playerToken = null; } // bug TODO

  if (!playerToken) {
    playerToken = localStorage.coupToken = prompt('Your name please:', Math.random().toString(36).substring(7));
  }

  // TODO: better sanitize (pass token instead of name)
  playerToken = playerToken.replace(/\W/g, '');

  var base = '';
  var pbase = base + '/games/abc/players/' + playerToken;

  return {

    resetGame: function () {
      return $http.post(pbase + '/reset');
    },

    loseCard: function (cardToken) {
      return $http.post(pbase + '/lose/' + cardToken);
    },

    adjustMoney: function (amount) {
      return $http.post(pbase + '/adjust_money/' + amount);
    },

    returnCard: function (cardToken) {
      return $http.post(pbase + '/return/' + cardToken);
    },

    draw: function (amount) {
      return $http.post(pbase + '/draw?cards=' + amount.toString());
    },

    refresh: function () {
      return $http.get(pbase);
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
    if (!confirm('Are you sure?')) { return; }
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
    if (amount > 0) {
      return $scope.game.hand.money <= 10;
    } else {
      var res = $scope.game.hand.money + amount;
      return res >= 0;
    }
  };

  $scope.resetGame = function () {
    if (!confirm('Are you sure?')) { return; }
    GameService.resetGame().then(function (response) {
      $scope.game = response.data;
    });
  };

  // BOOTSTRAP
  $scope.game = { hand: { money: 0 } };
  $scope.reloadGame();

  $interval($scope.reloadGame, 3000);

}]);
