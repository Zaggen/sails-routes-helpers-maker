expect = require('chai').expect
helpersMaker = require('../index')

describe 'route-based-helpers Module', ->
  it 'should have a make method', ->
    expect(helpersMaker.make).to.be.a('function')

  describe 'When using a single language routes obj', ->
    routes =
      'GET /': 'HomeController.index'
      '/magazines': 'MagazinesController.index'
      'GET /photo-album/:id/:slug': 'PhotosController.show'
      'PUT /photo-album/:id/:slug': 'NewsController.update'
      'DELETE /photo-album/:id/:slug': 'NewsController.destroy'
      'GET /photo-album': 'PhotosController.index'
      'GET /photo-album/new': 'PhotosController.new'
      'GET /photo-album/:id/:slug/edit': 'PhotosController.edit'
      'POST /photo-album': 'PhotosController.create'
      'GET /admin/login': 'AdminController.index' # This kind of route does not work (admin should be defined as a namespace)

    helpers = helpersMaker.make(routes)

    it 'should create a homePath method when a route / is provided', ->
      expect(helpers.homePath).to.be.a('function')

    it 'should create a helper for a given route even when no http verb is specified ', ->
      expect(helpers.magazinesPath).to.be.a('function')

    it 'should create a photoAlbumPath method when a route /photo-album/ is provided', ->
      expect(helpers.photoAlbumPath).to.be.a('function')
      expect(helpers.newPhotoAlbumPath).to.be.a('function')
      expect(helpers.editPhotoAlbumPath).to.be.a('function')

    describe 'The created helpers', ->
      describe 'homePath helper', ->
        it 'should return the root path', ->
          expect(helpers.homePath()).to.equal('/')

      describe 'photos related helpers', ->

        mockedInstance =
          id: 1
          slug: 'the-amazing-spiderman'
          toParam: -> "#{@id}/#{@slug}"


        console.log {helpers}

        describe 'photoAlbumPath helper', ->

          it 'should return the index path when no instance is passed as argument', ->
            expect(helpers.photoAlbumPath()).to.equal('/photo-album')

          it 'should return the show path when a model instance is passed as argument', ->
            expect(helpers.photoAlbumPath(mockedInstance)).to.equal("/photo-album/#{mockedInstance.id}/#{mockedInstance.slug}")

          it 'should throw an error when the passed instance does not contains a .toParam method', ->
            expect(-> helpers.photoAlbumPath({id:1})).to.throw(Error)

          it 'should return the same path no matter how many times it was called', ->
            expect(helpers.photoAlbumPath()).to.equal(helpers.photoAlbumPath())

        describe 'editPhotoAlbumPath helper', ->
          it 'should return the edit path when a model instance is passed as argument', ->
            expect(helpers.editPhotoAlbumPath(mockedInstance)).to.equal("/photo-album/#{mockedInstance.id}/#{mockedInstance.slug}/edit")

        describe 'newPhotoAlbumPath helper', ->
          it 'should return the edit path when nothing is passed as argument', ->
            expect(helpers.newPhotoAlbumPath()).to.equal("/photo-album/new")

          it 'should return the same path no matter how many times it was called', ->
            expect(helpers.newPhotoAlbumPath()).to.equal(helpers.newPhotoAlbumPath())

      describe 'loginAdminPath() helper', ->
        it 'should return the same path no matter how many times it was called', ->
          expect(helpers.loginAdminPath()).to.equal(helpers.loginAdminPath())

  describe 'When using a multiple language routes obj', ->
    multilingualRoutes =
      'GET /': 'HomeController.index'
      'GET /photo-album/:id/:slug': 'PhotosController.show'
      'PUT /photo-album/:id/:slug': 'NewsController.update'
      'DELETE /photo-album/:id/:slug': 'NewsController.destroy'
      'GET /photo-album': 'PhotosController.index'
      'GET /photo-album/new': 'PhotosController.new'
      'GET /photo-album/:id/:slug/edit': 'PhotosController.edit'
      'POST /photo-album': 'PhotosController.create'

      'GET /album-fotografico/:id/:slug': 'PhotosController.show'
      'PUT /album-fotografico/:id/:slug': 'NewsController.update'
      'DELETE /album-fotografico/:id/:slug': 'NewsController.destroy'
      'GET /album-fotografico': 'PhotosController.index'
      'GET /album-fotografico/new': 'PhotosController.new'
      'GET /album-fotografico/:id/:slug/edit': 'PhotosController.edit'
      'POST /album-fotografico': 'PhotosController.create'

    routesLocales =
      '/': {en: '/', es: '/'}
      '/photo-album': {en: '/photo-album', es: '/album-fotografico'}

    toParam = (lang)-> "#{@id}/#{@translatedSlugs[lang]}"

    multilingualHelpers = helpersMaker.make(multilingualRoutes, routesLocales)

    it 'should create a homePath method, given that a root path "/" was provided', ->
      expect(multilingualHelpers.homePath).to.be.a('function')

    it 'should create a photoAlbumPath method when a route /photo-album/ is provided', ->
      expect(multilingualHelpers.photoAlbumPath).to.be.a('function')
      expect(multilingualHelpers.newPhotoAlbumPath).to.be.a('function')
      expect(multilingualHelpers.editPhotoAlbumPath).to.be.a('function')

    describe 'The created helpers', ->

      describe 'homePath helper', ->
        it 'should return the root path', ->
          expect(multilingualHelpers.homePath()).to.equal('/')
          expect(multilingualHelpers.homePath('es')).to.equal('/es/')

      describe 'photos related helpers', ->

        mockedInstance =
          id: 1, slug: 'the-amazing-spiderman',
          translatedSlugs: {'en': 'the-amazing-spiderman', 'es': 'el-increible-spiderman'}
          toParam: toParam

        describe 'photoAlbumPath helper', ->

          it 'should return the index path when no instance is passed as argument and language is not passed', ->
            expect(multilingualHelpers.photoAlbumPath()).to.equal('/photo-album')

          it 'should return the index path when no instance is passed as argument and language is passed', ->
            expect(multilingualHelpers.photoAlbumPath('es')).to.equal('/es/album-fotografico')

          xit 'should throw an error when a language is passed as first arg (a string) and a second argument(any)', ->
            expect(-> multilingualHelpers.photoAlbumPath('es', mockedInstance)).to.throw(Error)

          it 'should return the show path when a model instance and language code are passed as argument', ->
            lang = 'en'
            expect(multilingualHelpers.photoAlbumPath(mockedInstance, lang)).to.equal("/photo-album/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}")
            lang = 'es'
            expect(multilingualHelpers.photoAlbumPath(mockedInstance, lang)).to.equal("/es/album-fotografico/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}")

          it 'should throw an error when an instance is passed, without the .toParam method', ->
            expect(-> multilingualHelpers.photoAlbumPath({id: 1, slug: 'the-amazing-spiderman'})).to.throw(Error)


        describe 'editPhotoAlbumPath helper', ->
          it 'should return the edit path when a model instance is passed as argument', ->
            lang = 'en'
            expect(multilingualHelpers.editPhotoAlbumPath(mockedInstance)).to.equal("/photo-album/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}/edit")
            lang = 'es'
            expect(multilingualHelpers.editPhotoAlbumPath(mockedInstance, 'es')).to.equal("/es/album-fotografico/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}/edit")


        describe 'newPhotoAlbumPath helper', ->
          it 'should return the edit path when nothing is passed as argument', ->
            expect(multilingualHelpers.newPhotoAlbumPath()).to.equal("/photo-album/new")
            expect(multilingualHelpers.newPhotoAlbumPath('en')).to.equal("/photo-album/new")
            expect(multilingualHelpers.newPhotoAlbumPath('es')).to.equal("/es/album-fotografico/new")



      describe 'When passing a language code to the make method', ->
        multilingualHelpers2 = helpersMaker.make(multilingualRoutes, routesLocales, 'es')

        describe 'photoAlbumPath helper', ->
          it 'should return the index path on the new default language when no instance is passed as argument and language is not passed', ->
            expect(multilingualHelpers2.photoAlbumPath()).to.equal('/es/album-fotografico')


      describe 'When a routesLocales object is passed, but not all routesNames are specified in the locales', ->
        multilingualRoutes =
          'GET /': 'HomeController.index'
          'GET /admin': 'AdminController.index'
          'GET /photo-album/:id/:slug': 'PhotosController.show'
          'GET /album-fotografico/:id/:slug': 'PhotosController.show'

        routesLocales =
          '/album-fotografico': {en: '/photo-album', es: '/album-fotografico'}

        multilingualHelpers3 = helpersMaker.make(multilingualRoutes, routesLocales)
        it 'should make a regular version of the path fn to the route that does not have a corresponding locale', ->
          expect(multilingualHelpers3.homePath()).to.equal('/')
          expect(-> multilingualHelpers3.homePath('es')).to.throw(Error)

          expect(multilingualHelpers3.adminPath()).to.equal('/admin')
          expect(-> multilingualHelpers3.adminPath('es')).to.throw(Error)

          expect(multilingualHelpers3.photoAlbumPath()).to.equal('/photo-album')
          expect(multilingualHelpers3.photoAlbumPath('es')).to.equal('/es/album-fotografico')

