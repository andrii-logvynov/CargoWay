Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint('http://invalidaddress74654374556wete');
request.setMethod('GET');
for (Integer i = 0; i < 101; i++) {
    HttpResponse response = http.send(request);
}
