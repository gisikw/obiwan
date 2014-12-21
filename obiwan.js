angular.module('obiwan', []).controller('obiwanCtrl', function ($scope, $http, $sce) {

  var previewFrame = document.getElementById('obi-frame');

  $scope.preview = {
    active: false,
    width:  '970',
    code:   '',
    bg:     'light'
  };

  $scope.openPreview = function (doc) {
    previewFrame.contentWindow.document.body.innerHTML = doc.code;
    $scope.preview.active = true;
  };

  window.obiwanData = function (data) {
    var node, fragment = document.createDocumentFragment(), i = data.docs.length;
    $scope.categories = data.categories;
    $scope.docs = data.docs;

    while(i) {
      i -= 1;
      $scope.docs[i].code = $sce.trustAsHtml($scope.docs[i].code);
      $scope.docs[i].copy = $sce.trustAsHtml($scope.docs[i].copy);
    }

    i = data.deps.stylesheets.length;
    while(i) {
      i -= 1;
      node = document.createElement('link');
      node.rel = 'stylesheet';
      node.type = 'text/css';
      node.href = data.deps.stylesheets[i];
      fragment.appendChild(node);
    }

    document.head.appendChild(fragment.cloneNode(true));
    previewFrame.contentWindow.document.head.appendChild(fragment);
  };

  $http.jsonp('docs.jsonp')

  // Get rid of this
  $scope.currentCategory = 'Basics';

});
