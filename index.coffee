_ = require('lodash')

newsRoutesHelpers = require('def-type').Module ->

  fnSuffix = 'Path'
  routeSetParamsQ = {}
  siteDefaultLang = 'en'

  @make = (routesObj = {}, routesLocales, multilingualHelperDefaultLang = siteDefaultLang)->
    helpers = {}
    completeRouteLocalesDictionary(routesLocales)
    for route of routesObj
      routeFragments = route.split('/')
      httpVerb = routeFragments.shift() # Not used yet
      routeName = routeFragments.shift()
      routeParams = []
      controllerAction = null
      isMultilingual = no

      if routesLocales?
        routePath = "/#{routeName}"
        if routesLocales[routePath]?
          currentRouteLocale = routesLocales[routePath]
          # if it is multilingual but is not the default routeName then skip to avoid creating
          # helpers in different languages, we only want to create the default one, that can return all language versions.
          if currentRouteLocale[siteDefaultLang] is routePath
            isMultilingual = yes
          else
            continue

      # Filters route parameters and actions from the routeFragments
      for fragment in routeFragments
        if fragment.charAt(0) is ':'
          routeParams.push(fragment.substring(1))
        else
          controllerAction = fragment

      helperName = getHelperName(routeName, controllerAction)

      if isMultilingual
        fn = getMultilingualPathFn(routeName, routeParams, controllerAction, routesLocales, multilingualHelperDefaultLang)
      else
        fn = getPathFn(routeName, routeParams, controllerAction)

      if not helpers[helperName]?
        helpers[helperName] = fn

    return helpers

  completeRouteLocalesDictionary = (routesLocales)->
    for routeKey, translations of routesLocales
      for lang, route of translations
        if not routesLocales[route]? and route isnt '/'
          routesLocales[route] = translations
    return routesLocales      

  getHelperName = (routeName, controllerAction)->
    routeName = _.camelCase(if routeName is '' then 'home' else routeName)
    if controllerAction?
      controllerAction + _.capitalize(routeName) + fnSuffix
    else
      routeName + fnSuffix

  getPathFn = (routeName, params, action)->
    basePath = if routeName isnt 'home' then "/#{routeName}" else "/"
    return (instance)->
      path = basePath
      if instance?
        if not instance.toParam? then throw new Error "Expected instance.toParam() to exist but couldn't find it"
        path += "/#{instance.toParam()}"

      if action?
        path += "/#{action}"
      return path

  getMultilingualPathFn = (routeName, params, action, routesLocales, multilingualHelperDefaultLang)->
    return (instance, lang = multilingualHelperDefaultLang)->
      # When only the language is passed, we then set the lang parameter to the first argument,
      # and make sure the instance is null
      if _.isString(instance)
        lang = arguments[0]
        instance = null

      path = getLocalizedPath(routeName, routesLocales, lang)
      if instance?
        if not instance.toParam? then throw new Error "Expected instance.toParam() to exist but couldn't find it"
        path += "/#{instance.toParam(lang)}"

      if action?
        path += "/#{action}"
      return path

  getLocalizedPath = (routeName, routesLocales, lang)->
    path = routesLocales["/#{routeName}"][lang]
    path = if lang is siteDefaultLang then path else "/#{lang}#{path}"
    return path

module.exports = newsRoutesHelpers