function pdf()
{
	interaction="-interaction=batchmode"
	[ "$TRACE"x == "true"x ] && interaction=""
	TPLDIR=$1
	shift
	classList=($@)

	# 支持随机选取theme
	setClass "${classList[*]}"
	
	for t in ${SELECTED[@]};do
		init
		cd $BUILD

		note "pdfClass: $t"
		note "use -E copyright=(true|false) to control whether or not to compile copyright page"
		note "use -E licence=(ccnd|ccnc|ccncnd|ccncsa|ccncsand|pd"		
		addOptions="$origAddOptions"
		PANDOCVARS="$ORIGPANDOCVARS"
		division="--top-level-division=default"
		
		# copy pdf class
		PDFCLASSDIR=$SCRIPTDIR/templates/$TPLDIR/$t
		USERDEFINECLASS=$cwd/templates/$TPLDIR/$t
		if [ -d $PDFCLASSDIR -o -d $USERDEFINECLASS ];then
			cp -rfu $PDFCLASSDIR $BUILD 2>/dev/null
			cp -rfu $USERDEFINECLASS $BUILD 2>/dev/null
			# 需要删除.md文件
			rm -f $t/*.md
			rm -f $t/*.pdf
			cp -rfu $t/* .
		fi
	
		PANDOCVARS="$PANDOCVARS -V documentclass=$t"
		TEX_OUTPUT="$ofile-$TPL-$t-$device.tex"

		info "PANDOCVARS: $PANDOCVARS"
		info "addOptions: $addOptions"
		info "LSTSET: $LSTSET"
		info "division: $division"
		info "copyright: $copyright"
		info "licence: $licence"
				
		source $SCRIPTDIR/config.default		
		[ -f $cwd/config ] && source $cwd/config
		PDF_OPTIONS="$PDF_OPTIONS -B frontmatter.tex -A backmatter.tex --metadata-file=$METADATA"		

		# 打补丁. 补丁放在templates/$TPLDIR/classname 文件夹下，命名规则 patch-$classname.sh
		[ -f patch-$t.sh ] && source patch-$t.sh
		[ -f $t.lua ] && CUSTOM_FILTER=" --lua-filter $t.lua" || CUSTOM_FILTER=""
		
		[ "$LSTSET"x != ""x ] && (cat $LSTSET;echo) >> $HEADERS
		# 版权页
		copyrightPage
		[ "$copyright"x == "true"x ] && (cat $COPYPAGE;echo) >> $HEADERS
		# 支持 fenced_divs语法的columns
		[ "$columns"x == "true"x ] && addOptions="$addOptions $COLUMNS_SUPPORT"
		addOptions="$addOptions $copyoption"
		
		trimHeader
		# 生成前言和后记		
		pandoc $FRONTMATTER -o frontmatter.tex --listings $division $CUSTOM_FILTER
		pandoc $BACKMATTER -o backmatter.tex --listings $division $CUSTOM_FILTER
		pandoc $PANDOC_REFERENCE_PARAM $BODY -o $TEX_OUTPUT $PDF_OPTIONS $division $addOptions $PANDOCVARS
		
		sed -i -E "/begin\{lstlisting.*label.*\]/ s/caption=(.*)?,\s*label=(.*)\]/caption=\1, label=\2, float=htbp\]/" $TEX_OUTPUT
		sed -i -E "/begin\{lstlisting.*label.*\]/ s/\[label=(.*)?\]/\[label=\1, caption=\1, float=htbp\]/" $TEX_OUTPUT
		
		# gif格式图片编译报错，需要引用eps格式，需转换后使用
		sed -i -r "s#(\includegraphics\{.*?).(gif)(\})#\1.eps\3#g" $TEX_OUTPUT
		
		# 网络图片需要替换为本地文件
		sed -i -r "s#(\includegraphics\{)http(s)?://(.*)#\1$IMGDIRRELATIVE/\3#g" $TEX_OUTPUT
		
		xelatex $interaction -output-directory=$BUILD $TEX_OUTPUT #1&>/dev/null
		xelatex $interaction -output-directory=$BUILD $TEX_OUTPUT #1&>/dev/null
		compileStatus PDF
	done
	
	clean
}

function func_thesis()
{
	getVar TPL "latex"
	getVar DOCUMENTCLASS "elegantpaper"
	classList=(elegantpaper)
	pdf "thesis" "${classList[*]}"
}

function func_book()
{
	getVar TPL "latex"
	getVar DOCUMENTCLASS "ctexbook"
	getVar device "pc"
	classList=(ctexbook book elegantbook ctexart article)
	pdf "book" "${classList[*]}"
}