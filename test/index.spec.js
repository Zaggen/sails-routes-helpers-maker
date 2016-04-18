// Generated by CoffeeScript 1.10.0
(function() {
  var expect, helpersMaker;

  expect = require('chai').expect;

  helpersMaker = require('../index');

  describe('route-based-helpers Module', function() {
    it('should have a make method', function() {
      return expect(helpersMaker.make).to.be.a('function');
    });
    describe('When using a single language routes obj', function() {
      var helpers, routes;
      routes = {
        'GET /': 'HomeController.index',
        '/magazines': 'MagazinesController.index',
        'GET /photo-album/:id/:slug': 'PhotosController.show',
        'PUT /photo-album/:id/:slug': 'NewsController.update',
        'DELETE /photo-album/:id/:slug': 'NewsController.destroy',
        'GET /photo-album': 'PhotosController.index',
        'GET /photo-album/new': 'PhotosController.new',
        'GET /photo-album/:id/:slug/edit': 'PhotosController.edit',
        'POST /photo-album': 'PhotosController.create',
        'GET /admin/login': 'AdminController.index'
      };
      helpers = helpersMaker.make(routes);
      it('should create a homePath method when a route / is provided', function() {
        return expect(helpers.homePath).to.be.a('function');
      });
      it('should create a helper for a given route even when no http verb is specified ', function() {
        return expect(helpers.magazinesPath).to.be.a('function');
      });
      it('should create a photoAlbumPath method when a route /photos/ is provided', function() {
        expect(helpers.photoAlbumPath).to.be.a('function');
        expect(helpers.newphotoAlbumPath).to.be.a('function');
        return expect(helpers.editphotoAlbumPath).to.be.a('function');
      });
      return describe('The created helpers', function() {
        describe('homePath helper', function() {
          return it('should return the root path', function() {
            return expect(helpers.homePath()).to.equal('/');
          });
        });
        describe('photos related helpers', function() {
          var mockedInstance;
          mockedInstance = {
            id: 1,
            slug: 'the-amazing-spiderman',
            toParam: function() {
              return this.id + "/" + this.slug;
            }
          };
          console.log({
            helpers: helpers
          });
          describe('photoAlbumPath helper', function() {
            it('should return the index path when no instance is passed as argument', function() {
              return expect(helpers.photoAlbumPath()).to.equal('/photos');
            });
            it('should return the show path when a model instance is passed as argument', function() {
              return expect(helpers.photoAlbumPath(mockedInstance)).to.equal("/photos/" + mockedInstance.id + "/" + mockedInstance.slug);
            });
            it('should throw an error when the passed instance does not contains a .toParam method', function() {
              return expect(function() {
                return helpers.photoAlbumPath({
                  id: 1
                });
              }).to["throw"](Error);
            });
            return it('should return the same path no matter how many times it was called', function() {
              return expect(helpers.photoAlbumPath()).to.equal(helpers.photoAlbumPath());
            });
          });
          describe('editphotoAlbumPath helper', function() {
            return it('should return the edit path when a model instance is passed as argument', function() {
              return expect(helpers.editphotoAlbumPath(mockedInstance)).to.equal("/photos/" + mockedInstance.id + "/" + mockedInstance.slug + "/edit");
            });
          });
          return describe('newphotoAlbumPath helper', function() {
            it('should return the edit path when nothing is passed as argument', function() {
              return expect(helpers.newphotoAlbumPath()).to.equal("/photos/new");
            });
            return it('should return the same path no matter how many times it was called', function() {
              return expect(helpers.newphotoAlbumPath()).to.equal(helpers.newphotoAlbumPath());
            });
          });
        });
        return describe('loginAdminPath() helper', function() {
          return it('should return the same path no matter how many times it was called', function() {
            return expect(helpers.loginAdminPath()).to.equal(helpers.loginAdminPath());
          });
        });
      });
    });
    return describe('When using a multiple language routes obj', function() {
      var multilingualHelpers, multilingualRoutes, routesLocales, toParam;
      multilingualRoutes = {
        'GET /': 'HomeController.index',
        'GET /photos/:id/:slug': 'PhotosController.show',
        'PUT /photos/:id/:slug': 'NewsController.update',
        'DELETE /photos/:id/:slug': 'NewsController.destroy',
        'GET /photos': 'PhotosController.index',
        'GET /photos/new': 'PhotosController.new',
        'GET /photos/:id/:slug/edit': 'PhotosController.edit',
        'POST /photos': 'PhotosController.create',
        'GET /fotos/:id/:slug': 'PhotosController.show',
        'PUT /fotos/:id/:slug': 'NewsController.update',
        'DELETE /fotos/:id/:slug': 'NewsController.destroy',
        'GET /fotos': 'PhotosController.index',
        'GET /fotos/new': 'PhotosController.new',
        'GET /fotos/:id/:slug/edit': 'PhotosController.edit',
        'POST /fotos': 'PhotosController.create'
      };
      routesLocales = {
        '/': {
          en: '/',
          es: '/'
        },
        '/photos': {
          en: '/photos',
          es: '/fotos'
        }
      };
      toParam = function(lang) {
        return this.id + "/" + this.translatedSlugs[lang];
      };
      multilingualHelpers = helpersMaker.make(multilingualRoutes, routesLocales);
      it('should create a homePath method, given that a root path "/" was provided', function() {
        return expect(multilingualHelpers.homePath).to.be.a('function');
      });
      it('should create a photoAlbumPath method when a route /photos/ is provided', function() {
        expect(multilingualHelpers.photoAlbumPath).to.be.a('function');
        expect(multilingualHelpers.newphotoAlbumPath).to.be.a('function');
        return expect(multilingualHelpers.editphotoAlbumPath).to.be.a('function');
      });
      return describe('The created helpers', function() {
        describe('homePath helper', function() {
          return it('should return the root path', function() {
            expect(multilingualHelpers.homePath()).to.equal('/');
            return expect(multilingualHelpers.homePath('es')).to.equal('/es/');
          });
        });
        describe('photos related helpers', function() {
          var mockedInstance;
          mockedInstance = {
            id: 1,
            slug: 'the-amazing-spiderman',
            translatedSlugs: {
              'en': 'the-amazing-spiderman',
              'es': 'el-increible-spiderman'
            },
            toParam: toParam
          };
          describe('photoAlbumPath helper', function() {
            it('should return the index path when no instance is passed as argument and language is not passed', function() {
              return expect(multilingualHelpers.photoAlbumPath()).to.equal('/photos');
            });
            it('should return the index path when no instance is passed as argument and language is passed', function() {
              return expect(multilingualHelpers.photoAlbumPath('es')).to.equal('/es/fotos');
            });
            xit('should throw an error when a language is passed as first arg (a string) and a second argument(any)', function() {
              return expect(function() {
                return multilingualHelpers.photoAlbumPath('es', mockedInstance);
              }).to["throw"](Error);
            });
            it('should return the show path when a model instance and language code are passed as argument', function() {
              var lang;
              lang = 'en';
              expect(multilingualHelpers.photoAlbumPath(mockedInstance, lang)).to.equal("/photos/" + mockedInstance.id + "/" + mockedInstance.translatedSlugs[lang]);
              lang = 'es';
              return expect(multilingualHelpers.photoAlbumPath(mockedInstance, lang)).to.equal("/es/fotos/" + mockedInstance.id + "/" + mockedInstance.translatedSlugs[lang]);
            });
            return it('should throw an error when an instance is passed, without the .toParam method', function() {
              return expect(function() {
                return multilingualHelpers.photoAlbumPath({
                  id: 1,
                  slug: 'the-amazing-spiderman'
                });
              }).to["throw"](Error);
            });
          });
          describe('editphotoAlbumPath helper', function() {
            return it('should return the edit path when a model instance is passed as argument', function() {
              var lang;
              lang = 'en';
              expect(multilingualHelpers.editphotoAlbumPath(mockedInstance)).to.equal("/photos/" + mockedInstance.id + "/" + mockedInstance.translatedSlugs[lang] + "/edit");
              lang = 'es';
              return expect(multilingualHelpers.editphotoAlbumPath(mockedInstance, 'es')).to.equal("/es/fotos/" + mockedInstance.id + "/" + mockedInstance.translatedSlugs[lang] + "/edit");
            });
          });
          return describe('newphotoAlbumPath helper', function() {
            return it('should return the edit path when nothing is passed as argument', function() {
              expect(multilingualHelpers.newphotoAlbumPath()).to.equal("/photos/new");
              expect(multilingualHelpers.newphotoAlbumPath('en')).to.equal("/photos/new");
              return expect(multilingualHelpers.newphotoAlbumPath('es')).to.equal("/es/fotos/new");
            });
          });
        });
        describe('When passing a language code to the make method', function() {
          var multilingualHelpers2;
          multilingualHelpers2 = helpersMaker.make(multilingualRoutes, routesLocales, 'es');
          return describe('photoAlbumPath helper', function() {
            return it('should return the index path on the new default language when no instance is passed as argument and language is not passed', function() {
              return expect(multilingualHelpers2.photoAlbumPath()).to.equal('/es/fotos');
            });
          });
        });
        return describe('When a routesLocales object is passed, but not all routesNames are specified in the locales', function() {
          var multilingualHelpers3;
          multilingualRoutes = {
            'GET /': 'HomeController.index',
            'GET /admin': 'AdminController.index',
            'GET /photos/:id/:slug': 'PhotosController.show',
            'GET /fotos/:id/:slug': 'PhotosController.show'
          };
          routesLocales = {
            '/fotos': {
              en: '/photos',
              es: '/fotos'
            }
          };
          multilingualHelpers3 = helpersMaker.make(multilingualRoutes, routesLocales);
          return it('should make a regular version of the path fn to the route that does not have a corresponding locale', function() {
            expect(multilingualHelpers3.homePath()).to.equal('/');
            expect(function() {
              return multilingualHelpers3.homePath('es');
            }).to["throw"](Error);
            expect(multilingualHelpers3.adminPath()).to.equal('/admin');
            expect(function() {
              return multilingualHelpers3.adminPath('es');
            }).to["throw"](Error);
            expect(multilingualHelpers3.photoAlbumPath()).to.equal('/photos');
            return expect(multilingualHelpers3.photoAlbumPath('es')).to.equal('/es/fotos');
          });
        });
      });
    });
  });

}).call(this);

//# sourceMappingURL=index.spec.js.map