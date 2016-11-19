package main

import (
  "github.com/golang/protobuf/proto"
  "encoding/json"
  "fmt"
  "net/http"
  pb "./protobuf"
)

func getLibrary() *pb.MyLibrary {
  m := make(map[string]string)
  m["route"] = "66"

  bookInfo := new(pb.BookInfo)
  bookInfo.Id = 10
  bookInfo.Title = "Welcome to Swift"
  bookInfo.Author = "Apple Inc."

  library := new(pb.MyLibrary)
  library.Id = 20
  library.Name = "Swift"
  library.Keys = m
  library.Books = []*pb.BookInfo{bookInfo}
  return library
}

func handler(w http.ResponseWriter, r *http.Request) {
  library := getLibrary()
  accept := r.Header.Get("Accept")

  var data []byte
  var err error

  if accept == "application/protobuf" {
    data, err = proto.Marshal(library)
    w.Header().Set("Content-Type", "application/protobuf")

  } else {
    data, err = json.Marshal(library)
    w.Header().Set("Content-Type", "application/json; charset=UTF-8")

  }

  if err != nil {
    fmt.Println("err:", err)
    w.WriteHeader(http.StatusInternalServerError)
    return
  }

  w.Write(data)
}

func main() {
  http.HandleFunc("/", handler)
  http.ListenAndServe(":8080", nil)
}
