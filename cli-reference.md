https://docs.aws.amazon.com/emulator/latest/userguide/cli-reference.md

# AWS Emulator command reference
<a name="cli-reference"></a>

The `aws-emulator` command starts an instance of AWS Emulator. You install it with the Linux package, or run it in a container that you build. For installation, see [Getting started with AWS Emulator](getting-started.md). The container takes the same options as the native command.

**Topics**
+ [Synopsis](#cli-reference-synopsis)
+ [Options](#cli-reference-options)
+ [Output](#cli-reference-output)
+ [Control routes](#cli-reference-routes)
+ [Local files](#cli-reference-files)
+ [Credentials and authentication](#cli-reference-credentials)
+ [When the port is in use](#cli-reference-port-in-use)
+ [Stopping the emulator](#cli-reference-stop)

## Synopsis
<a name="cli-reference-synopsis"></a>

The command takes only options. It has no subcommands.

```
aws-emulator [options]
```

With no options, the emulator listens for HTTPS requests on `127.0.0.1:9297`. It serves the AWS APIs and its health route on that one port. It runs in the foreground until you stop it.

## Options
<a name="cli-reference-options"></a>

The following table lists every option. Long options also accept the form `--option=value`, for example `--port=9300`. If you give an option that the emulator doesn’t know, it prints an error and exits with code 2.


| Option | Default | Description | 
| --- | --- | --- | 
|  `-b`, `--bind` {{ip}}  |  `127.0.0.1`  | The IP address that the emulator listens on. The value must be an IP address, not a host name. The default lets only your own machine reach the emulator. In a container, bind `0.0.0.0` so that Docker can forward the port. Use `0.0.0.0` only in a container, and publish the port on `127.0.0.1`. | 
|  `-p`, `--port` {{port}}  |  `9297`  | The port for HTTPS requests, from 0 to 65535. Use `0` to let the operating system pick a free port. Then read the actual port from the startup line of the log. For more information, see [Output](#cli-reference-output). To run several emulators side by side, give each one a different port. | 
|  `-a`, `--auth` {{on\|off}}  |  `on`  | Turns request authentication on or off. When it’s on, API requests must be signed with the keys of this run, except operations that AWS serves without a signature. When it’s off, the emulator serves every request and doesn’t write a credentials file. For more information, see [Credentials and authentication](#cli-reference-credentials). | 
|  `-t`, `--telemetry` {{on\|off}}  |  `on`  | Turns telemetry on or off for this run. `off` always turns telemetry off. `on` doesn’t override an opt-out that you set in an environment variable or the emulator settings file (`config.toml`). For more information, see [Telemetry in AWS Emulator](telemetry.md). | 
|  `--idle-timeout` {{seconds}}  | None | Stops the emulator after it receives no API call for the given number of seconds. The value is a whole number from 1 to 31536000 (one year). Use it in automated test runs so that a forgotten emulator doesn’t keep running. Without this option, the emulator runs until you stop it. | 
|  `-v`, `--version`  | None | Prints the version, the release date, and the commit that the release was built from, and then exits. | 
|  `-h`, `--help`  | None | Prints the list of options and the health route, and then exits. | 

## Output
<a name="cli-reference-output"></a>

The emulator writes its log to standard output as JSON lines, one JSON object for each line. When it’s ready, it writes one startup line, whose `message` field is `emulator server information`. The following table describes the fields in the startup line.


| Field | Description | 
| --- | --- | 
|  `endpoint_url`  | The URL that your tools use to reach the emulator, for example `https://127.0.0.1:9297`. | 
|  `health_check_url`  | The URL of the health route, for example `https://127.0.0.1:9297/__admin/health`. | 
|  `config_file`  | The path of the config file that it wrote. | 
|  `ca_file`  | The path of its certificate file (`ca.pem`). | 
|  `java_truststore_file`  | The path of its trust store for Java (`truststore.p12`). | 

You can rely on this line and its fields. Find it by its `message` field, not by its position, because other lines can come before it. For example, if you start the emulator with `-p 0`, read the actual port from `endpoint_url`. For the files, see [Local files](#cli-reference-files). For how to use them with your tools, see [Pointing your AWS SDK at AWS Emulator](point-sdk-to-emulator.md).

The emulator also writes one line of plain text to standard error. This telemetry notice says whether telemetry is on and how to turn it off. For more information, see [Telemetry in AWS Emulator](telemetry.md).

If the emulator listens on an address other than loopback, or if authentication is off, it also writes a warning line. This line says who can reach the emulator. The rest of the log isn’t a stable interface. Its fields can change in any release, and so can the help text. To check whether the emulator is ready, use the health route. For more information, see [Control routes](#cli-reference-routes).

## Control routes
<a name="cli-reference-routes"></a>

Besides the AWS APIs, the emulator serves one control route. It serves this route on the same port as the APIs, over HTTPS. There’s no separate admin port.


| Route | Description | 
| --- | --- | 
|  `GET /__admin/health`  | Returns HTTP 200 with the body `ok` when the emulator is working. Use it to wait for the emulator to start. | 

The following example checks the health of an emulator on the default port. It uses the certificate that the emulator wrote for that port.

```
curl --cacert ~/.aws/emulator/9297/ca.pem https://127.0.0.1:9297/__admin/health
```

To wait for the emulator in a script, use the loop in [To point your SDK at a local emulator](point-sdk-to-emulator.md#point-sdk-env).

The emulator doesn’t provide routes to reset state or to control state transitions. It keeps all state in memory. To start with empty state, restart the emulator.

## Local files
<a name="cli-reference-files"></a>

When it starts, the emulator writes the following files to a subdirectory of `~/.aws/emulator/` named for its port, for example `~/.aws/emulator/9297/`.


| File | Contents | 
| --- | --- | 
|  `emulator_credentials`  | The access key ID and secret access key for this run, in the format of an AWS shared credentials file. The emulator writes this file only when authentication is on. | 
|  `config`  | A `[default]` profile in the format of an AWS config file. It sets `region` to `us-east-1`, and it sets `endpoint_url` and `ca_bundle` for this emulator. It also sets the Amazon S3 `signature_version` to `s3v4`. | 
|  `ca.pem`  | The certificate that the emulator uses for HTTPS. The emulator creates a new certificate each time it starts. | 
|  `truststore.p12`  | The same certificate as `ca.pem`, in a Public-Key Cryptography Standards \#12 (PKCS12) trust store without a password, for Java. For more information, see [To trust the emulator certificate in Java](point-sdk-to-emulator.md#point-sdk-ca-java). | 

The emulator creates each file so that only your user can read and write it (mode 0600). It deletes the files when it stops cleanly. A clean stop is **Ctrl\+C**, `SIGTERM`, or an idle timeout set with `--idle-timeout`.

If the emulator crashes, the files stay. The next emulator that starts on the same port replaces them, so you don’t need to delete them yourself.

When you run the emulator in a container, the paths in `config` are paths inside the container. For the settings to use on your host, see [To point your SDK at a local emulator](point-sdk-to-emulator.md#point-sdk-env).

For the files that telemetry uses, see [Telemetry in AWS Emulator](telemetry.md).

## Credentials and authentication
<a name="cli-reference-credentials"></a>

By default, the emulator requires API requests to be signed with Signature Version 4 (SigV4). Operations that AWS serves without a signature, such as AWS STS `AssumeRoleWithWebIdentity`, don’t need one. The emulator accepts both signed headers and presigned URLs. Each time it starts, it generates a new key pair. Currently, the keys have the following format:
+ The access key ID is 20 characters long. It starts with `EMULATOR`, followed by 12 uppercase hexadecimal characters.
+ The secret access key is 40 uppercase hexadecimal characters.

The keys work only with the emulator run that generated them. They don’t expire while the emulator runs. They stop working when the emulator stops, and they don’t work with an emulator on another port.

The emulator rejects unsigned requests and requests signed with other keys. Keys that you create in the emulator itself, through IAM (`CreateAccessKey`) or AWS STS, also work. Some services accept requests that aren’t signed with standard SigV4. The emulator doesn’t handle those requests the same way as AWS. For more information, see [What we do](security.md#security-what-we-do).

The emulator rejects a request with HTTP 403, or with HTTP 404 if it can’t tell which service the request is for. The error depends on the reason, as shown in the following table.


| Reason | Error | 
| --- | --- | 
| The request isn’t signed | The error that the service returns on AWS, for example `InvalidClientTokenId` from AWS STS. | 
| The request is signed with a key that the emulator doesn’t accept |  `AccessDenied`, with the message "Sign the request with the emulator credentials". This error also covers a malformed signature, a credential scope that names the wrong service, and an expired presigned URL. | 
| The request uses a key that the emulator accepts, but the signature is wrong |  `SignatureDoesNotMatch`. The secret key is wrong, or the body doesn’t match the signature. | 
| The emulator can’t tell which service the request is for | HTTP 404 `UnknownService`. This often happens with an unsigned request, because the emulator usually reads the service from the signature. Sign the request with the emulator credentials, as described in [To point your SDK at a local emulator](point-sdk-to-emulator.md#point-sdk-env). | 

The emulator rejects a request whose signed time is more than 15 minutes from its own clock, as AWS does. It also rejects presigned URLs after they expire.

Each emulator acts as one AWS account, `000000000000`. To check that your tools talk to the emulator, see [To check that you’re using the emulator](point-sdk-to-emulator.md#point-sdk-verify).

If you start the emulator with `--auth off`, it serves every request, signed or not, and doesn’t write a credentials file. Before you use this option, see [What you do](security.md#security-what-you-do).

The size and format of the generated credentials can change in any release. Don’t validate them in your code.

## When the port is in use
<a name="cli-reference-port-in-use"></a>

If another process already uses the port, the emulator prints the following error, followed by an operating system error code. Then it exits with code 1.

```
emulator serve failed: server I/O error: Address already in use
```

The emulator writes no files in this case. The files of an emulator that already runs on that port stay as they are. To fix the error, choose another port with `-p`, or use `-p 0` to let the operating system pick a free port.

## Stopping the emulator
<a name="cli-reference-stop"></a>

The emulator runs in the foreground. To stop it, press **Ctrl\+C** or send the process `SIGTERM`. If you set `--idle-timeout`, the emulator also stops by itself after that idle time.

In each case, the emulator stops cleanly. It sends its final telemetry batch if telemetry is on, and deletes its files for that port. The emulator keeps all emulated resources in memory, so they’re gone when it stops.
