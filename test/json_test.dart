import 'package:flutter_test/flutter_test.dart';

import 'package:belnews/article.dart';

void main() {
  test('parse articles', () {
    final jsonStr = """{
    "status": "ok",
    "totalResults": 38,
    "articles": [
        {
            "source": {
                "id": null,
                "name": "Nytimes.com"
            },
            "author": null,
            "title": "Hong Kong Stocks Tumble on China Crackdown Worries: Live Business Updates - The New York Times",
            "description": "Live Stock Market News During the Coronavirus Pandemic",
            "url": "https://www.nytimes.com/2020/05/22/business/stock-market-today-coronavirus.html",
            "urlToImage": "https://www.nytimes.com/newsgraphics/2020/04/09/corona-virus-social-images-by-section/assets/Business_promo.jpg?u=1590135817372",
            "publishedAt": "2020-05-22T08:28:17Z",
            "content": "Heres what you need to know: Hong Kong stocks slump after China announces plans to tighten its grip. Hong Kong stocks fell by more than 5 percent in Friday trading after Chinese leaders announced their plans to tighten their grip over the territory and to i… [+6958 chars]"
        }
    ]
}""";
    expect(parseArticles(jsonStr)[0].title,
        "Hong Kong Stocks Tumble on China Crackdown Worries: Live Business Updates - The New York Times");
  });
}