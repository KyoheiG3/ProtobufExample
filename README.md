# ProtobufExample

In iOS, it is an example of handling Protocol Buffers. It is possible to response Protocol Buffers or JSON by requesting one PATH of API server.

### ProtobufClient

Client demo application for iOS.

Using [swift-protobuf](https://github.com/apple/swift-protobuf) for protocol buffers. also using [RxSwift](https://github.com/ReactiveX/RxSwift).

### ProtobufServer

API server of Swift.

In this example using [Kitura](http://www.kitura.io/).

### protos

Sample `.proto` files.

### server

API server of Go.


## Getting Started

First install various packages.

#### Prepare for `ProtobufClient`.

```
$ cd ./ProtobufClient
$ pod install
```

#### Prepare for `ProtobufServer`.

```
$ cd ./ProtobufServer
$ swift build
```

Create a project file if necessary.

```
$ swift package generate-xcodeproj
```

Start up the api or open the project file and run api.

```
$ ./.build/debug/api
```

#### Prepare for `server`.

```
$ go get github.com/golang/protobuf/protoc-gen-go
```

Start up the api.

```
$ go run server/api.go
```

## Compiling `.proto`

This process is not absolutely necessary.

#### Install protobuf

```
$ brew install protobuf
```

#### Compiling for Swift

Need to create `protoc-gen-swift`.

```
$ cd ./ProtobufServer
$ swift build
$ protoc --plugin=protoc-gen-swift=.build/debug/protoc-gen-swift --swift_out=../protos --proto_path=../protos ../protos/DataModel.proto
```

#### Compiling for Go

```
$ go get github.com/golang/protobuf/protoc-gen-go
$ cd ./protos
$ protoc --go_out=. DataModel.proto
```

## Generating Docs

Generate document using `protoc-gen-doc`

```
$ brew install qt5
$ brew link --force qt5
$ git clone https://github.com/estan/protoc-gen-doc.git
$ cd protoc-gen-doc
$ PROTOBUF_PREFIX=/usr/local/Cellar/protobuf/3.1.0 qmake
$ make && make install
```

Have to match `protobuf` version with `PROTOBUF_PREFIX`

#### Generate markdown

```
$ cd ./protos
$ protoc --doc_out=markdown,../docs.md:. *.proto
```

#### Generate html

```
$ cd ./protos
$ protoc --doc_out=html,../index.html:. *.proto
```

## LICENSE

Under the MIT license. See LICENSE file for details.
