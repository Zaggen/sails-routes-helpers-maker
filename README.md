# sails-routes-helpers-maker
It takes the object with all routes defined in it (sails.js routes) and create path helpers

This module is in beta, use at your own risk.

## Usage Example
```coffeescript
multilingualRoutes =
      'GET /': 'HomeController.show'
      'GET /photos/:id/:slug': 'PhotosController.show'
      'PUT /photos/:id/:slug': 'NewsController.update'
      'DELETE /photos/:id/:slug': 'NewsController.destroy'
      'GET /photos': 'PhotosController.index'
      'GET /photos/new': 'PhotosController.new'
      'GET /photos/:id/:slug/edit': 'PhotosController.edit'
      'POST /photos': 'PhotosController.create'

      'GET /fotos/:id/:slug': 'PhotosController.show'
      'PUT /fotos/:id/:slug': 'NewsController.update'
      'DELETE /fotos/:id/:slug': 'NewsController.destroy'
      'GET /fotos': 'PhotosController.index'
      'GET /fotos/new': 'PhotosController.new'
      'GET /fotos/:id/:slug/edit': 'PhotosController.edit'
      'POST /fotos': 'PhotosController.create'

    routeLocales =
      photos: {en: 'photos', es: 'fotos'}

    toParam = (lang)-> "#{@id}/#{@translatedSlugs[lang]}"

    helpers = helpersMaker.make(multilingualRoutes, routeLocales)

    # Creates the following helpers
    helpers.homePath() # returns '/'
    helpers.homePath('es') # returns 'es/'

    helpers.photosPath() # returns /photos
    helpers.photosPath('es') # returns /es/fotos
    # photoRecordInstance is a single record (object returned by waterline query), and has .toParams() instance method
    helpers.photosPath(photoRecordInstance, 'en') # returns /photos/23/amazing-sunrise
    helpers.photosPath(photoRecordInstance, 'es') # returns /es/fotos/23/amanecer-espectacular

    helpers.editPhotosPath() # returns /photos/23/amazing-sunrise/edit
    helpers.editPhotosPath('es') # returns /es/fotos/23/amanecer-espectacular/edit ... yes i need to handle the edit part in the future
    helpers.newPhotosPath() # returns /photos/new

```