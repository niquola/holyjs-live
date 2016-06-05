require('file?name=index.html!./index.html')

app = angular.module 'app', []


call_sql = ($http, $scope, sql, cb)->
  start = new Date()
  $http(method: 'POST', url: "http://localhost:8000/sql", data: {query: sql})
  .success (data)->
    $scope.error = null
    $scope.time = (new Date() - start)
    cb(data)
  .error (err)->
    $scope.result = null
    $scope.time = (new Date() - start)
    $scope.error = err

call_fn = ($http, $scope, fn, args, cb)->
  $http(method: 'POST', url: "http://localhost:8000/fn/#{fn}", data: args)
  .error (err)-> $scope.error = err

app.controller 'IndexCtrl', ($scope, $http)->

  reload = ()->
    call_sql $http, $scope, 'SELECT * FROM slides ORDER BY position', (slides)->
      $scope.slides = slides
      if not $scope.slide
        $scope.slide = slides[0]

  $scope.create = (title, code)->
    call_fn $http, $scope, "add_slide", {title: title, code: code}
      .success (data)->
        console.log('created', data)
        reload()

  $scope.remove = (sl)->
    form = $scope.form
    call_fn $http, $scope, "rm_slide", sl
      .success ()->
        $scope.slide = null
        reload()

  $scope.update = (sl)->
    form = $scope.form
    call_fn $http, $scope, "update_slide", sl
      .success (data)-> $scope.slide = data

  $scope.execute = (sql)->
    $scope.result = [{status: "Loading...."}]
    call_sql $http, $scope, sql, (data)->
      $scope.result = data

  $scope.setSlide = (sl)->
    $scope.slide = sl
    $scope.execute(sl.code)

  $scope.keypress = (ev, sql)->
    console.log(ev)
    if ev.keyCode == 13 && ev.ctrlKey
      $scope.execute(sql)

  $scope.up = (sl)->
    call_fn $http, $scope, "up_slide", sl
      .success (data)-> reload()

  $scope.down = (sl)->
    call_fn $http, $scope, "down_slide", sl
      .success (data)-> reload()

  reload()

window.app = app
