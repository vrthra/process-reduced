.extracted: reduced.tar.gz
	zcat $< | tar -xpf -
	touch .extracted

reduced.tar.gz:
	wget http://web.engr.oregonstate.edu/~alipourm/tmp/reduced.tar.gz

generate: .extracted
	 for i in suitreduction-data/reduced_testsuites/reduced_*/*/*-ts; do echo $$i; ./src/process.rb $$i; echo; done 
