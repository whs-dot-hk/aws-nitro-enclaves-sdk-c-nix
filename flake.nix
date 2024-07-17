{
  inputs.aws-lc.url = "github:awslabs/aws-lc/v1.12.0";
  inputs.s2n-tls.url = "github:aws/s2n-tls/v1.3.46";
  inputs.aws-c-common.url = "github:awslabs/aws-c-common/v0.8.0";
  inputs.aws-c-sdkutils.url = "github:awslabs/aws-c-sdkutils/v0.1.2";
  inputs.aws-c-io.url = "github:awslabs/aws-c-io/v0.11.0";
  inputs.aws-c-compression.url = "github:awslabs/aws-c-compression/v0.2.14";
  inputs.aws-c-http.url = "github:awslabs/aws-c-http/v0.7.6";
  inputs.aws-c-cal.url = "github:awslabs/aws-c-cal/v0.5.18";
  inputs.aws-c-auth.url = "github:awslabs/aws-c-auth/v0.6.15";
  inputs.aws-nitro-enclaves-nsm-api.url = "github:aws/aws-nitro-enclaves-nsm-api/v0.4.0";
  inputs.json-c.url = "github:json-c/json-c/json-c-0.16-20220414";

  inputs.aws-lc.flake = false;
  inputs.s2n-tls.flake = false;
  inputs.aws-c-common.flake = false;
  inputs.aws-c-sdkutils.flake = false;
  inputs.aws-c-io.flake = false;
  inputs.aws-c-compression.flake = false;
  inputs.aws-c-http.flake = false;
  inputs.aws-c-cal.flake = false;
  inputs.aws-c-auth.flake = false;
  inputs.aws-nitro-enclaves-nsm-api.flake = false;
  inputs.json-c.flake = false;

  outputs = _: {};
}
