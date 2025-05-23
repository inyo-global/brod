KAFKA_VERSION ?= 4.0.0
export KAFKA_VERSION
all: compile

compile:
	@rebar3 compile

lint:
	@rebar3 lint

test-env:
	@./scripts/gen-certs.sh
	@./scripts/setup-test-env.sh
	@mkdir -p ./test/data/ssl
	@cp ./scripts/certs/ca.pem ./test/data/ssl/ca.pem
	@cp ./scripts/certs/client.key ./test/data/ssl/client-key.pem
	@cp ./scripts/certs/client.pem ./test/data/ssl/client-crt.pem

ut:
	@rebar3 eunit -v --cover_export_name ut-$(KAFKA_VERSION)

# version check, eunit and all common tests
t: ut
	@rebar3 ct -v --cover_export_name ct-$(KAFKA_VERSION)

clean:
	@rebar3 clean
	@rm -rf _build
	@rm -rf ebin deps doc
	@rm -f pipe.testdata

hex-publish: clean
	@rebar3 hex publish --repo=hexpm
	@rebar3 hex build

## tests that require kafka running at localhost
INTEGRATION_CTS = brod_cg_commits brod_client brod_compression brod_consumer brod_producer brod_group_subscriber brod_topic_subscriber brod

cover:
	@rebar3 cover -v

dialyzer:
	@rebar3 dialyzer
