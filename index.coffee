_ = require('lodash')

newsRoutesHelpers = require('def-inc').Module ->

  fnSuffix = 'Path'
  routeSetParamsQ = {}
  siteDefaultLang = 'en'

  @make = (routesObj, routeLocales, multilingualHelperDefaultLang = siteDefaultLang)->
    helpers = {}
    for route of routesObj
      routeFragments = route.split('/')
      httpVerb = routeFragments.shift() # Not used yet
      routeName = if (routeName = routeFragments.shift()) is '' then routeName = 'home' else routeName
      routeParams = []
      controllerAction = null
      isMultilingual = no

      if routeLocales?
        if routeLocales[routeName]?
          currentRouteLocale = routeLocales[routeName]
          # if it is multilingual but is not the default routeName then skip to avoid creating
          # helpers in different languages, we only want to create the default one, that can return all language versions.
          if currentRouteLocale[siteDefaultLang] isnt routeName and routeName isnt 'home'
            continue
          isMultilingual = yes

      for fragment in routeFragments
        if fragment.charAt(0) is ':'
          routeParams.push(fragment.substring(1))
        else
          controllerAction = fragment

      helperName = getHelperName(routeName, controllerAction)

      if isMultilingual
        fn = getMultilingualPathFn(routeName, routeParams, controllerAction, routeLocales, multilingualHelperDefaultLang)
      else
        fn = getPathFn(routeName, routeParams, controllerAction)

      if not helpers[helperName]?
        helpers[helperName] = fn

    return helpers

  getHelperName = (routeName, controllerAction)->
    if controllerAction?
      controllerAction + _.capitalize(routeName) + fnSuffix
    else
      routeName + fnSuffix

  getPathFn = (routeName, params, action)->
    path = if routeName isnt 'home' then "/#{routeName}" else "/"
    return (instance)->
      if instance?
        if not instance.toParam? then throw new Error "Expected instance.toParam() to exist but couldn't find it"
        path += "/#{instance.toParam()}"

      if action?
        path += "/#{action}"
      return path

  getMultilingualPathFn = (routeName, params, action, routeLocales, multilingualHelperDefaultLang)->
    return (instance, lang = multilingualHelperDefaultLang)->
      # When only the language is passed, we then set the lang parameter to the first argument,
      # and make sure the instance is null
      if _.isString(instance)
        lang = arguments[0]
        instance = null

      path = getLocalizedPath(routeName, routeLocales, lang)
      if instance?
        if not instance.toParam? then throw new Error "Expected instance.toParam() to exist but couldn't find it"
        path += "/#{instance.toParam(lang)}"

      if action?
        path += "/#{action}"
      return path

  getLocalizedPath = (routeName, routeLocales, lang)->
    path = "/#{routeLocales[routeName][lang]}"
    path = if lang is siteDefaultLang then path else "/#{lang}#{path}"
    return path

module.exports = newsRoutesHelpers