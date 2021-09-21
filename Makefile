default: asegparse

asegparse:
	julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.build(); Pkg.precompile()"
	cp .stash/asegparse .
	chmod +x asegparse
	@echo "asegparse built successfully"

.PHONY: clean

clean:
	rm asegparse
