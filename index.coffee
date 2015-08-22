_ = require('lodash')

newsRoutesHelpers = require('def-inc').Module ->

  fnSuffix = 'Path'
  routeSetParamsQ = {}
  multilingualRoutes = {}
  siteDefaultLang = 'en'

  @make = (routesObj, routeLocales)->
    helpers = {}
    for route of routesObj
      routeFragments = route.split('/')
      httpVerb = routeFragments.shift() # Not used yet
      routeName = if (routeName = routeFragments.shift()) is '' then routeName = 'home' else routeName
      baseRoute = "/#{routeName}"
      routeParams = []
      controllerAction = null

      #isMultilingual = if routeLocales? and routeLocales[routeName]? then yes else no
      if routeLocales?
        currentRouteLocale = routeLocales[routeName] if routeLocales[routeName]?
        if currentRouteLocale[siteDefaultLang] isnt routeName then continue
        isMultilingual = yes
      else
        isMultilingual = no

      # if it is multilingual but is not the default routeName then skip

      for fragment in routeFragments
        if fragment.charAt(0) is ':'
          routeParams.push(fragment.substring(1))
        else
          controllerAction = fragment

      if controllerAction?
        helperName = controllerAction + _.capitalize(routeName) + fnSuffix
      else
        helperName = routeName + fnSuffix

      if routeParams.length > 0
        if routeSetParamsQ[routeName]? and routeSetParamsQ[routeName] isnt routeParams.length
          errMsg = """
          The routes related to /#{routeName} have inconsistent parameters,
          this module can't guess which one should use, please modify those
          routes to have the same number of parameters """
          throw new Error(errMsg)
        routeSetParamsQ[routeName] = routeParams.length

      if isMultilingual
        fn = getMultilingualPathFn(routeName, routeParams, controllerAction, routeLocales, siteDefaultLang)
      else
        fn = getPathFn(baseRoute, routeParams, controllerAction)

      if not helpers[helperName]?
        helpers[helperName] = fn

    return helpers

  getPathFn = (path, params, action)->
    return (instance)->
      if instance?
        for expectedParam in params
          if not instance[expectedParam]?
            throw new Error "Expected the #{expectedParam} property in the passed instance but couldn't find it"
          path += "/#{instance[expectedParam]}"

      if action?
        path += "/#{action}"
      return path

  getMultilingualPathFn = (routeName, params, action, routeLocales, defaultLang)->
    return (instance, lang = siteDefaultLang)->
      # When only the language is passed, we then set the lang parameter to the first argument,
      # and make sure the instance is null
      if _.isString(instance)
        if arguments.length is 1
          lang = arguments[0]
          instance = null
        else
          errMsg = """
                Expected first parameter (instance) to be an object, if you are passing language as the first
                parameter, do not pass more arguments to it.
                """
          throw new Error(errMsg)

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