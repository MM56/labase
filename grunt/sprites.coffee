module.exports = (grunt) ->
    grunt.registerTask "sprites", ->
        options = grunt.option "globalConfig"
        src = [ 'src/img/sprites/**/1x','src/img/sprites/**/2x' ]
        grunt.file.mkdir( "src/scss/sprites" )
        grunt.file.expand({ filter: 'isDirectory' }, src).forEach (path, index) ->
            
            tpl = 'grunt/config/template@1x.mustache'
            tpl = 'grunt/config/template@2x.mustache' if path.indexOf("2x") > -1

            imgPath = "sprites/" + path.replace(options.srcPath + "/img/","") + ".png"

            padding = 4
            padding = 8 if path.indexOf("2x") > -1
            obj = 
                src : path + "/*.png"
                dest : "<%= globalConfig.buildPath %>/img/sprites/" + path.replace(options.srcPath + "/img/","") + ".png"
                destCss : "<%= globalConfig.srcPath %>/scss/sprites/sprite-"+index+".scss"
                cssTemplate: tpl
                padding: padding
                imgPath : imgPath
                cssVarMap: (sprite) ->
                    sprite.folder = sprite.source_image.substr(0, sprite.source_image.indexOf('/1x/')).replace('src/img/', '').replace(new RegExp(/\//g), '-')
                    sprite.retina = imgPath.replace "1x", "2x"
                    return

            grunt.config('sprite.' + index, obj)
        grunt.task.run(['sprite'])
        grunt.task.run(["concat:sprites"])
        grunt.task.run(["clean:sass"])