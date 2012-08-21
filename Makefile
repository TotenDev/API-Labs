build:
	@echo "Compiling LESS..."
	@lessc --compress less/bootstrap.less > css/style.css
	@lessc --compress less/responsive.less > css/mobile.css
	@echo "Compiling Coffeescript..."
	@coffee -cj js/main.js js/main.coffee
	@echo "Compiling Handlebars templates..."
	@handlebars templates/menu-content.handlebars templates/tab-content.handlebars templates/nav-content.handlebars -f js/templates.js
	@echo "Packaging things up..."
	@cat js/vendor/jquery.js js/vendor/bootstrap.js js/vendor/handlebars.js js/templates.js js/main.js > js/application.js
	@rm js/templates.js js/main.js
	@echo "Done!"

clean:
	@rm js/application.js