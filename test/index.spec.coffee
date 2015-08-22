expect = require('chai').expect
helpersMaker = require('../index')

describe 'route-based-helpers Module', ->
  it 'should have a make method', ->
    expect(helpersMaker.make).to.be.a('function')

  describe 'When using a single language routes obj', ->
    routes =
      'GET /photos/:id/:slug': 'PhotosController.show'
      'PUT /photos/:id/:slug': 'NewsController.update'
      'DELETE /photos/:id/:slug': 'NewsController.destroy'
      'GET /photos': 'PhotosController.index'
      'GET /photos/new': 'PhotosController.new'
      'GET /photos/:id/:slug/edit': 'PhotosController.edit'
      'POST /photos': 'PhotosController.create'

    helpers = helpersMaker.make(routes)

    it 'should create a photosPath method when a route /photos/ is provided', ->
      expect(helpers.photosPath).to.be.a('function')
      expect(helpers.newPhotosPath).to.be.a('function')
      expect(helpers.editPhotosPath).to.be.a('function')

    describe 'The created helpers', ->
      mockedInstance = {id: 1, slug: 'the-amazing-spiderman'}
      describe 'photosPath helper', ->
        it 'should return the index path when no instance is passed as argument', ->
          expect(helpers.photosPath()).to.equal('/photos')

        it 'should return the show path when a model instance is passed as argument', ->
          expect(helpers.photosPath(mockedInstance)).to.equal("/photos/#{mockedInstance.id}/#{mockedInstance.slug}")

        it 'should throw an error when the passed instance does not contains the expected parameters to make the path', ->
          expect(-> helpers.photosPath({id:1})).to.throw(Error)

      describe 'editPhotosPath helper', ->
        it 'should return the edit path when a model instance is passed as argument', ->
          expect(helpers.editPhotosPath(mockedInstance)).to.equal("/photos/#{mockedInstance.id}/#{mockedInstance.slug}/edit")

      describe 'newPhotosPath helper', ->
        it 'should return the edit path when nothing is passed as argument', ->
          expect(helpers.newPhotosPath()).to.equal("/photos/new")

      describe 'When a route set with inconsistent params are passed', ->
        inconsistentRoutes =
          'GET /photos/:id/:slug': 'PhotosController.show'
          'PUT /photos/:id/': 'NewsController.update'
          'DELETE /photos/:id': 'NewsController.destroy'
          'GET /photos': 'PhotosController.index'
          'GET /photos/new': 'PhotosController.new'
          'GET /photos/:id/edit': 'PhotosController.edit'
          'POST /photos': 'PhotosController.create'

        throwingFn = ->
          helpersMaker.make(inconsistentRoutes)

        it 'should throw an error', ->
          expect(throwingFn).to.throw(Error)

  describe 'When using a multiple language routes obj', ->
    multilingualRoutes =
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

    photosLocales = {en: 'photos', es: 'fotos'}
    routeLocales =
      photos: photosLocales
      fotos: photosLocales

    multilingualHelpers = helpersMaker.make(multilingualRoutes, routeLocales)

    it 'should create a photosPath method when a route /photos/ is provided', ->
      expect(multilingualHelpers.photosPath).to.be.a('function')
      expect(multilingualHelpers.newPhotosPath).to.be.a('function')
      expect(multilingualHelpers.editPhotosPath).to.be.a('function')

    describe 'The created helpers', ->
      toParam = (lang)-> "#{@id}/#{@translatedSlugs[lang]}"

      mockedInstance = {id: 1, slug: 'the-amazing-spiderman', translatedSlugs: {'en': 'the-amazing-spiderman', 'es': 'el-increible-spiderman'}, toParam}
      describe 'photosPath helper', ->
        it 'should return the index path when no instance is passed as argument and language is not passed', ->
          expect(multilingualHelpers.photosPath()).to.equal('/photos')

        it 'should return the index path when no instance is passed as argument and language is passed', ->
          expect(multilingualHelpers.photosPath('es')).to.equal('/es/fotos')

        it 'should throw an error when a language is passed as first arg (a string) and a second argument(any)', ->
          expect(-> multilingualHelpers.photosPath('es', mockedInstance)).to.throw(Error)

        it 'should return the show path when a model instance and language code are passed as argument', ->
          lang = 'en'
          expect(multilingualHelpers.photosPath(mockedInstance, lang)).to.equal("/photos/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}")
          lang = 'es'
          expect(multilingualHelpers.photosPath(mockedInstance, lang)).to.equal("/es/fotos/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}")

        it 'should throw an error when an instance is passed, without the .toParam method', ->
          expect(-> multilingualHelpers.photosPath({id: 1, slug: 'the-amazing-spiderman'})).to.throw(Error)

      describe 'editPhotosPath helper', ->
        it 'should return the edit path when a model instance is passed as argument', ->
          lang = 'en'
          expect(multilingualHelpers.editPhotosPath(mockedInstance)).to.equal("/photos/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}/edit")
          lang = 'es'
          expect(multilingualHelpers.editPhotosPath(mockedInstance, 'es')).to.equal("/es/fotos/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}/edit")

      describe 'newPhotosPath helper', ->
        it 'should return the edit path when nothing is passed as argument', ->
          expect(multilingualHelpers.newPhotosPath()).to.equal("/photos/new")
          expect(multilingualHelpers.newPhotosPath('en')).to.equal("/photos/new")
          expect(multilingualHelpers.newPhotosPath('es')).to.equal("/es/fotos/new")

