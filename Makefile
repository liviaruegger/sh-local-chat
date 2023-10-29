entrega = ep2.sh docs/relatorio.pdf

permission:
	chmod u+r+x ep2.sh

tar:
	mkdir ep2-ana_livia_saldanha
	cp $(entrega) ep2-ana_livia_saldanha/
	tar zcvf ep2-ana_livia_saldanha.tar.gz ep2-ana_livia_saldanha
	rm -r ep2-ana_livia_saldanha