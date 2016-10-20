module FrontPage exposing(view)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Messages exposing(..) 
import Debug exposing(..)
import Json.Decode as Json exposing(..)
import Date exposing(Date)
import DatePickers exposing (from, to)




onChange : (Date -> Msg) -> Attribute Msg
onChange tagger =  
  --on "onchange" (Json.map (log "tagger " >> tagger) targetValue)
  on "input" (Json.customDecoder targetValue (Date.fromString >> (Result.map tagger)) )

  
--onChange Messages.SetDateTime
view :  Html Msg
view = 
 body [ class "page-home" ]
  [ div [ class "wrapper" ]
    [ div [ class "slider" ]
      []
    , main' [ class "main-fluid clearfix" ]
      [ section [ class "main-section" ]
        [ div [ class "clearfix" ]
          [ h1 []
            [ text "Сеть отелей Екатерина" ]
          , img [ alt "About hotel", class "image--welcome" ]
            []
          , p []
            [ text "Наш отель в Одессе располагает 16 элегантными и просторными номерами для гостей, в том числе двумя просторными Семейными номерами.          " ]
          , p []
            [ text "Интерьеры отличаются теплым, уютным декором. Каждый номер сохранил свою оригинальность.          Все номера гостиницы декорированы в различных цветовых гаммах и оборудованы по лучшим стандартам, которые только могут предложить отели Одессы.          В каждом из них имеется элегантный вход, удобная двух спальная кровать, оформленная ванная комната с комплектом банных принадлежностей, а так же и гостиной зоной для расслабляющего отдыха гостей.          " ]
          , p []
            [ text "Стильный декор и комфортабельная меблировка каждого номера являются изящным отражением гостеприимства.          " ]
          ]
        , h2 []
          [ text "Отель в центре Одессы" ]
        , h3 []
          [ text "Каждый номер гостиницы оборудован в соответствии с мировыми стандартами:" ]
        , ul []
          [ li []
            [ text "Система климат-контроля \"Daikin\"" ]
          , li []
            [ text "Телефон" ]
          , li []
            [ text "Wi-Fi Интернет" ]
          , li []
            [ text "Плазменный телевизор" ]
          , li []
            [ text "Кабельное телевидение" ]
          , li []
            [ text "Мини-бар" ]
          , li []
            [ text "Мини-сейф" ]
          ]
        , dl []
          [ dt []
            [ text "Для вашего комфортного пребывания в каждом номере есть дополнительные удобства:" ]
          , node "di" []
            [ text "Банный халат" ]
          , node "di" []
            [ text "Тапочки" ]
          , node "di" []
            [ text "Набор махровых полотенец" ]
          , node "di" []
            [ text "Фен" ]
          , node "di" []
            [ text "Косметический набор для душа" ]
          , node "di" [ ]
            [ text "В распоряжении клиентов круглосуточный отдел регистрации." ]
          , node "di" []
            [ text "Ежедневная уборка номеров." ]
          , node "di" []
            [ text "Стоянка автомашины – 40 грн. в сутки" ]
          ]
        , p []
          [ text "Мы готовы дарить своим гостям самые роскошные условия для отдыха, самый предупредительный сервис в атмосфере абсолютного спокойствия и уединения,            лучшие цены на апартаменты в Одессе.        " ]
        , p []
          [ text "Пребывание в отеле \"Екатерина\" оставит незабываемые впечатления, и Вам непременно захочется возвращаться к нам и снова осуществлять бронирование гостиниц.        " ]
        ],
        App.map DPMSG from,
        App.map DPMSG to,
         button [name "submit", onClick Messages.SubmitDates]
         [text "submit"]
     ]
    ]
  ]
