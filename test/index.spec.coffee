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

    it 'should create a photoAlbumPath method when a route /photos/ is provided', ->
      expect(helpers.photoAlbumPath).to.be.a('function')
      expect(helpers.newphotoAlbumPath).to.be.a('function')
      expect(helpers.editphotoAlbumPath).to.be.a('function')

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
            expect(helpers.photoAlbumPath()).to.equal('/photos')

          it 'should return the show path when a model instance is passed as argument', ->
            expect(helpers.photoAlbumPath(mockedInstance)).to.equal("/photos/#{mockedInstance.id}/#{mockedInstance.slug}")

          it 'should throw an error when the passed instance does not contains a .toParam method', ->
            expect(-> helpers.photoAlbumPath({id:1})).to.throw(Error)

          it 'should return the same path no matter how many times it was called', ->
            expect(helpers.photoAlbumPath()).to.equal(helpers.photoAlbumPath())

        describe 'editphotoAlbumPath helper', ->
          it 'should return the edit path when a model instance is passed as argument', ->
            expect(helpers.editphotoAlbumPath(mockedInstance)).to.equal("/photos/#{mockedInstance.id}/#{mockedInstance.slug}/edit")

        describe 'newphotoAlbumPath helper', ->
          it 'should return the edit path when nothing is passed as argument', ->
            expect(helpers.newphotoAlbumPath()).to.equal("/photos/new")

          it 'should return the same path no matter how many times it was called', ->
            expect(helpers.newphotoAlbumPath()).to.equal(helpers.newphotoAlbumPath())

      describe 'loginAdminPath() helper', ->
        it 'should return the same path no matter how many times it was called', ->
          expect(helpers.loginAdminPath()).to.equal(helpers.loginAdminPath())

  describe 'When using a multiple language routes obj', ->
    multilingualRoutes =
      'GET /': 'HomeController.index'
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

    routesLocales =
      '/': {en: '/', es: '/'}
      '/photos': {en: '/photos', es: '/fotos'}

    toParam = (lang)-> "#{@id}/#{@translatedSlugs[lang]}"

    multilingualHelpers = helpersMaker.make(multilingualRoutes, routesLocales)

    it 'should create a homePath method, given that a root path "/" was provided', ->
      expect(multilingualHelpers.homePath).to.be.a('function')

    it 'should create a photoAlbumPath method when a route /photos/ is provided', ->
      expect(multilingualHelpers.photoAlbumPath).to.be.a('function')
      expect(multilingualHelpers.newphotoAlbumPath).to.be.a('function')
      expect(multilingualHelpers.editphotoAlbumPath).to.be.a('function')

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
            expect(multilingualHelpers.photoAlbumPath()).to.equal('/photos')

          it 'should return the index path when no instance is passed as argument and language is passed', ->
            expect(multilingualHelpers.photoAlbumPath('es')).to.equal('/es/fotos')

          xit 'should throw an error when a language is passed as first arg (a string) and a second argument(any)', ->
            expect(-> multilingualHelpers.photoAlbumPath('es', mockedInstance)).to.throw(Error)

          it 'should return the show path when a model instance and language code are passed as argument', ->
            lang = 'en'
            expect(multilingualHelpers.photoAlbumPath(mockedInstance, lang)).to.equal("/photos/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}")
            lang = 'es'
            expect(multilingualHelpers.photoAlbumPath(mockedInstance, lang)).to.equal("/es/fotos/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}")

          it 'should throw an error when an instance is passed, without the .toParam method', ->
            expect(-> multilingualHelpers.photoAlbumPath({id: 1, slug: 'the-amazing-spiderman'})).to.throw(Error)


        describe 'editphotoAlbumPath helper', ->
          it 'should return the edit path when a model instance is passed as argument', ->
            lang = 'en'
            expect(multilingualHelpers.editphotoAlbumPath(mockedInstance)).to.equal("/photos/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}/edit")
            lang = 'es'
            expect(multilingualHelpers.editphotoAlbumPath(mockedInstance, 'es')).to.equal("/es/fotos/#{mockedInstance.id}/#{mockedInstance.translatedSlugs[lang]}/edit")


        describe 'newphotoAlbumPath helper', ->
          it 'should return the edit path when nothing is passed as argument', ->
            expect(multilingualHelpers.newphotoAlbumPath()).to.equal("/photos/new")
            expect(multilingualHelpers.newphotoAlbumPath('en')).to.equal("/photos/new")
            expect(multilingualHelpers.newphotoAlbumPath('es')).to.equal("/es/fotos/new")



      describe 'When passing a language code to the make method', ->
        multilingualHelpers2 = helpersMaker.make(multilingualRoutes, routesLocales, 'es')

        describe 'photoAlbumPath helper', ->
          it 'should return the index path on the new default language when no instance is passed as argument and language is not passed', ->
            expect(multilingualHelpers2.photoAlbumPath()).to.equal('/es/fotos')


      describe 'When a routesLocales object is passed, but not all routesNames are specified in the locales', ->
        multilingualRoutes =
          'GET /': 'HomeController.index'
          'GET /admin': 'AdminController.index'
          'GET /photos/:id/:slug': 'PhotosController.show'
          'GET /fotos/:id/:slug': 'PhotosController.show'

        routesLocales =
          '/fotos': {en: '/photos', es: '/fotos'}

        multilingualHelpers3 = helpersMaker.make(multilingualRoutes, routesLocales)
        it 'should make a regular version of the path fn to the route that does not have a corresponding locale', ->
          expect(multilingualHelpers3.homePath()).to.equal('/')
          expect(-> multilingualHelpers3.homePath('es')).to.throw(Error)

          expect(multilingualHelpers3.adminPath()).to.equal('/admin')
          expect(-> multilingualHelpers3.adminPath('es')).to.throw(Error)

          expect(multilingualHelpers3.photoAlbumPath()).to.equal('/photos')
          expect(multilingualHelpers3.photoAlbumPath('es')).to.equal('/es/fotos')

