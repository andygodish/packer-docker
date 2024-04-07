.PHONY: ubuntu2204 ubuntu2204-debug

ubuntu2204:
	packer init ubuntu2204/packer.pkr.hcl
	packer build -var-file variables.pkrvars.hcl ubuntu2204/packer.pkr.hcl

ubuntu2204-debug:
	packer init ubuntu2204/packer.pkr.hcl
	PACKER_LOG=1 PACKER_LOG_TIMESTAMP=1 packer build -var-file variables.pkrvars.hcl ubuntu2204/packer.pkr.hcl