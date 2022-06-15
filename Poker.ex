# Ke Zhang 500832394
defmodule Poker do

  # convert the list to string [1,2,3,4] -> ["1C","2C","3C","4C"]
  def conversion(list) do
    for card <- list do
      cond do
      (div(card - 1, 13) == 0) ->
        Integer.to_string(card) <> "C"  # Clubs
      (div(card - 1, 13) == 1) ->
        Integer.to_string(card - 13 * div(card - 1, 13)) <> "D"  # Diamonds
      (div(card - 1, 13) == 2) ->
        Integer.to_string(card - 13 * div(card - 1, 13)) <> "H"  # Hearts
      (div(card - 1, 13) == 3) ->
        Integer.to_string(card - 13 * div(card - 1, 13)) <> "S"  # Spades
      end
    end
  end

  # ignore the suit of cards
  def ignoreSuit(list) do
    for card <- list do
      cond do
      (String.at(card, -1) == "C") ->
        String.to_integer(String.trim(card,"C"))  # Clubs
      (String.at(card, -1) == "D") ->
        String.to_integer(String.trim(card,"D"))  # Diamonds
      (String.at(card, -1) == "H") ->
        String.to_integer(String.trim(card,"H"))  # Hearts
      (String.at(card, -1) == "S") ->
        String.to_integer(String.trim(card,"S"))  # Spades
      end
    end
  end

  # handOne's cards has position (1 3 5 6 7 8 9), which means remove 2nd and 4th element in the list
  def handOne(list) do
    newList = List.delete_at(list, 1) # remove 2nd element, (1 3 4 5 6 7 8 9)
    List.delete_at(newList, 2) # remove 4th element, position shift from 3 -> 2
  end

  # handTwo's cards has position (2 4 5 6 7 8 9), which means remove 1st and 3th element in the list
  def handTwo(list) do
    newList = List.delete_at(list, 0) # remove 1st element, (2 3 4 5 6 7 8 9)
    List.delete_at(newList, 1) # remove 3th element, position shift from 2 -> 1
  end

  # filter the list with suit: C
  def cListFilter(list) do
    newList = conversion(Enum.sort(list))
    Enum.filter(newList, fn(card) -> String.at(card,-1) == "C" end)
  end
  # filter the list with suit: D
  def dListFilter(list) do
    newList = conversion(Enum.sort(list))
    Enum.filter(newList, fn(card) -> String.at(card,-1) == "D" end)
  end
  # filter the list with suit: H
  def hListFilter(list) do
    newList = conversion(Enum.sort(list))
    Enum.filter(newList, fn(card) -> String.at(card,-1) == "H" end)
  end
  # filter the list with suit: S
  def sListFilter(list) do
    newList = conversion(Enum.sort(list))
    Enum.filter(newList, fn(card) -> String.at(card,-1) == "S" end)
  end

  # check if it is Flush
  def isFlush(list) do
    # string
    cList = cListFilter(list)
    dList = dListFilter(list)
    hList = hListFilter(list)
    sList = sListFilter(list)
    # string length
    cLength = length(cList)
    dLength = length(dList)
    hLength = length(hList)
    sLength = length(sList)

    cond do
      (cLength >= 5) ->
        cList
      (dLength >= 5) ->
        dList
      (hLength >= 5) ->
        hList
      (sLength >= 5) ->
        sList
      (cLength < 5 || dLength < 5 || hLength < 5 || sLength < 5) ->
        false
    end
  end

  # return Flush, as well as RoyalFlush
  def returnFlush(list) do
    flush = isFlush(list)
    newList = ignoreSuit(flush)
    if Enum.member?(newList, 1) do
      Enum.take(flush, 1) ++ Enum.take(flush, -4)
    else
      Enum.take(flush, -5)
    end
  end

  # Flush score calculation, as well as Straight
  def flushScore(list) do
    newList = Enum.reverse(ignoreSuit(returnFlush(list)))
    [first, second, third, fourth, last] = newList
    if (last == 1) do # special case for A
      (10000 * (last + 15)) + (1000 * first) + (100 * second) + (10 * third) + fourth
    else
      (10000 * first) + (1000 * second) + (100 * third) + (10 * fourth) + last
    end
  end

  # check if it is StraightFlush
  def isStraightFlush(list) do
    straightFlushCheck = isFlush(list)
    if (straightFlushCheck !== false) do
      straightFlush = ignoreSuit(isFlush(list))
      [ first, second, third | _ ] = straightFlush
      if (Enum.any?(straightFlush, fn(num) -> num == (first + 1) end) && Enum.any?(straightFlush, fn(num) -> num == (first + 2)end)
      && Enum.any?(straightFlush, fn(num) -> num == (first + 3)end) && Enum.any?(straightFlush, fn(num) -> num == (first + 4)end)) do
        true
      else
        if (Enum.any?(straightFlush, fn(num) -> num == (second  + 1) end) && Enum.any?(straightFlush, fn(num) -> num == (second  + 2)end)
        && Enum.any?(straightFlush, fn(num) -> num == (second  + 3)end) && Enum.any?(straightFlush, fn(num) -> num == (second + 4)end)) do
          true
        else
          if (Enum.any?(straightFlush, fn(num) -> num == (third + 1) end) && Enum.any?(straightFlush, fn(num) -> num == (third  + 2)end)
          && Enum.any?(straightFlush, fn(num) -> num == (third + 3)end) && Enum.any?(straightFlush, fn(num) -> num == (third + 4)end)) do
            true
          else
            false
          end
        end
      end
    else
      straightFlushCheck
    end
  end
  # return StraightFlush
  def returnStraightFlush(list) do
    straightFlush = ignoreSuit(isFlush(list))
    [ head | _ ] = isFlush(list)
    suit = String.at(head, -1)
    [ first, second, third | _ ] = straightFlush
    if (Enum.any?(straightFlush, fn(num) -> num == (third + 1) end) && Enum.any?(straightFlush, fn(num) -> num == (third + 2)end)
    && Enum.any?(straightFlush, fn(num) -> num == (third + 3)end) && Enum.any?(straightFlush, fn(num) -> num == (third + 4)end)) do
      [Integer.to_string(third) <> suit, Integer.to_string(third + 1) <> suit , Integer.to_string(third + 2) <> suit,
      Integer.to_string(third + 3) <> suit, Integer.to_string(third + 4) <> suit]
    else
      if (Enum.any?(straightFlush, fn(num) -> num == (second + 1) end) && Enum.any?(straightFlush, fn(num) -> num == (second + 2)end)
      && Enum.any?(straightFlush, fn(num) -> num == (second + 3)end) && Enum.any?(straightFlush, fn(num) -> num == (second + 4)end)) do
        [Integer.to_string(second) <> suit, Integer.to_string(second + 1) <> suit , Integer.to_string(second + 2) <> suit,
        Integer.to_string(second + 3) <> suit, Integer.to_string(second + 4) <> suit]
      else
        if (Enum.any?(straightFlush, fn(num) -> num == (first + 1) end) && Enum.any?(straightFlush, fn(num) -> num == (first + 2)end)
        && Enum.any?(straightFlush, fn(num) -> num == (first + 3)end) && Enum.any?(straightFlush, fn(num) -> num == (first + 4)end)) do
          [Integer.to_string(first) <> suit, Integer.to_string(first + 1) <> suit , Integer.to_string(first + 2) <> suit,
          Integer.to_string(first + 3) <> suit, Integer.to_string(first + 4) <> suit]
        else
          false
        end
      end
    end
  end
  # StraightFlush score calculation
  def straightFlushScore(list) do
    newList = Enum.reverse(ignoreSuit(returnStraightFlush(list)))
    [first, second, third, fourth, last] = newList
    (10000 * first) + (1000 * second) + (100 * third) + (10 * fourth) + last
  end

  # check if it is RoyalFlush
  def isRoyalFlush(list) do
    royalFlush = isFlush(list)
    if (royalFlush !== false) do
      if (Enum.member?(royalFlush, "1C") && Enum.member?(royalFlush, "10C") && Enum.member?(royalFlush, "11C")
      && Enum.member?(royalFlush, "12C") && Enum.member?(royalFlush, "13C")) do # [ "10C", "11C", "12C", "13C", "1C" ]
        true
      else
        if (Enum.member?(royalFlush, "1D") && Enum.member?(royalFlush, "10D") && Enum.member?(royalFlush, "11D")
        && Enum.member?(royalFlush, "12D") && Enum.member?(royalFlush, "13D")) do # [ "10D", "11D", "12D", "13D", "1D" ]
          true
        else
          if (Enum.member?(royalFlush, "1H") && Enum.member?(royalFlush, "10H") && Enum.member?(royalFlush, "11H")
          && Enum.member?(royalFlush, "12H") && Enum.member?(royalFlush, "13H")) do # [ "10H", "11H", "12H", "13H", "1H" ]
            true
          else
            if (Enum.member?(royalFlush, "1S") && Enum.member?(royalFlush, "10S") && Enum.member?(royalFlush, "11S")
            && Enum.member?(royalFlush, "12S") && Enum.member?(royalFlush, "13S")) do # [ "10S", "11S", "12S", "13S", "1S" ]
              true
            else
              false
            end
          end
        end
      end
    else
      royalFlush
    end
  end

  # check if it is Straight
  def isStraight(list) do
    straight = Enum.sort(ignoreSuit(conversion(list)))
    [ first, second, third | _ ] = straight
    if (Enum.any?(straight, fn(num) -> num == (first + 1) end) && Enum.any?(straight, fn(num) -> num == (first + 2)end)
    && Enum.any?(straight, fn(num) -> num == (first + 3)end) && Enum.any?(straight, fn(num) -> num == (first + 4)end)) do
      true
    else
      if (Enum.any?(straight, fn(num) -> num == (second  + 1) end) && Enum.any?(straight, fn(num) -> num == (second  + 2)end)
      && Enum.any?(straight, fn(num) -> num == (second  + 3)end) && Enum.any?(straight, fn(num) -> num == (second + 4)end)) do
        true
      else
        if (Enum.any?(straight, fn(num) -> num == (third + 1) end) && Enum.any?(straight, fn(num) -> num == (third  + 2)end)
        && Enum.any?(straight, fn(num) -> num == (third + 3)end) && Enum.any?(straight, fn(num) -> num == (third + 4)end)) do
          true
        else
          false
        end
      end
    end
  end
  # return Straight
  def returnStraight(list) do
    straight = Enum.sort(ignoreSuit(conversion(list)))
    [ first, second, third | _ ] = straight
    if (Enum.any?(straight, fn(num) -> num == (first + 1) end) && Enum.any?(straight, fn(num) -> num == (first + 2)end)
    && Enum.any?(straight, fn(num) -> num == (first + 3)end) && Enum.any?(straight, fn(num) -> num == (first + 4)end)) do
      result = Enum.filter(list, fn(card) -> (rem(card - 1, 13) == first - 1 || rem(card - 1, 13) == first ||
      rem(card - 1, 13) == first + 1 || rem(card - 1, 13) == first + 2 || rem(card - 1, 13) == first + 3) end)
      conversion(result)
    else
      if (Enum.any?(straight, fn(num) -> num == (second  + 1) end) && Enum.any?(straight, fn(num) -> num == (second  + 2)end)
      && Enum.any?(straight, fn(num) -> num == (second  + 3)end) && Enum.any?(straight, fn(num) -> num == (second + 4)end)) do
        result = Enum.filter(list, fn(card) -> (rem(card - 1, 13) == second - 1 || rem(card - 1, 13) == second ||
        rem(card - 1, 13) == second + 1 || rem(card - 1, 13) == second + 2 || rem(card - 1, 13) == second + 3) end)
        conversion(result)
      else
        if (Enum.any?(straight, fn(num) -> num == (third + 1) end) && Enum.any?(straight, fn(num) -> num == (third  + 2)end)
        && Enum.any?(straight, fn(num) -> num == (third + 3)end) && Enum.any?(straight, fn(num) -> num == (third + 4)end)) do
          result = Enum.filter(list, fn(card) -> (rem(card - 1, 13) == third - 1 || rem(card - 1, 13) == third ||
          rem(card - 1, 13) == third + 1 || rem(card - 1, 13) == third + 2 || rem(card - 1, 13) == third + 3) end)
          conversion(result)
        else
          false
        end
      end
    end
  end

  # check if it is FourOfAKind
  def isFourOfAKind(list) do
    fourOfAKind = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(fourOfAKind, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    maxFrequency = Enum.reverse(Enum.Enum.sort(Map.values(frequency)))
    [ head | _ ] = maxFrequency
    if head == 4 do
      true
    else
      false
    end
  end
  # return FourOfAKind
  def returnFourOfAKind(list) do
    fourOfAKind = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(fourOfAKind, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    value = Enum.find(frequency, fn {_, val} -> val == 4 end)
    key = elem(value, 0)
    [key <> "C", key <> "D", key <> "H", key <> "S"]
  end
  # FourOfAKind score calculation
  def fourOfAKindScore(list) do
    newList = Enum.reverse(ignoreSuit(returnFourOfAKind(list)))
    [ head | _ ] = newList
    if (head == 1) do # special case for A
      (head + 15) * 4
    else
      head * 4
    end
  end

  # check if it is Full House
  def isFullHouse(list) do
    fullHouse = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(fullHouse, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    maxFrequency = Enum.reverse(Enum.Enum.sort(Map.values(frequency)))
    [first, second | _ ] = maxFrequency
    if (first == 3 && second == 2 )do
      true
    else
      false
    end
  end
  # return FullHouse
  def returnFullHouse(list) do
    fullHouse = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(fullHouse, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    value1 = Enum.find(frequency, fn {_, val} -> val == 3 end)
    key1 = String.to_integer(elem(value1, 0))
    value2 = Enum.find(frequency, fn {_, val} -> val == 2 end)
    key2 = String.to_integer(elem(value2, 0))
    result = Enum.filter(list, fn(card) -> (rem(card - 1, 13) == key1 - 1 || rem(card - 1, 13) == key2 - 1) end)
    conversion(result)
  end
  # FullHouse score calculation
  def fullHouseScore(list) do
    fullHouse = Enum.sort(ignoreSuit(returnFullHouse(list)))
    [ head, _, _, _, tail ] = fullHouse
    if (head == 1) do # special case for A
      (head + 15) * 30 + tail * 2
    else
      if (tail == 1) do # special case for A
        head * 30 + (tail + 15) * 2
      else
        head * 30 + tail * 2
      end
    end
  end

  # check if it is ThreeOfAKind
  def isThreeOfAKind(list) do
    threeOfAKind = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(threeOfAKind, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    maxFrequency = Enum.reverse(Enum.Enum.sort(Map.values(frequency)))
    [first, second | _ ] = maxFrequency
    if (first == 3 && second !== 2 )do
      true
    else
      false
    end
  end
  # return ThreeOfAKind
  def returnThreeOfAKind(list) do
    threeOfAKind = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(threeOfAKind, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    value = Enum.find(frequency, fn {_, val} -> val == 3 end)
    key = String.to_integer(elem(value, 0))
    result = Enum.filter(list, fn(card) -> (rem(card - 1, 13) == key - 1) end)
    conversion(result)
  end
  # threeOfAKindscore calculation
  def threeOfAKindScore(list) do
    threeOfAKind = Enum.sort(ignoreSuit(returnThreeOfAKind(list)))
    [ head | _ ] = threeOfAKind
    if (head == 1) do # special case for A
      (head + 15) * 3
    else
      head * 3
    end
  end

  # check if it is TwoPairs
  def isTwoPairs(list) do
    twoPairs = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(twoPairs, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    maxFrequency = Enum.reverse(Enum.Enum.sort(Map.values(frequency)))
    [first, second | _ ] = maxFrequency
    if (first == 2 && second == 2 )do
      true
    else
      false
    end
  end
  # return TwoPairs
  def returnTwoPairs(list) do
    # 1st pair
    twoPairs1 = ignoreSuit(conversion(Enum.sort(list)))
    newList1 = Enum.map(twoPairs1, &Integer.to_string/1)
    frequency1 = Enum.frequencies(newList1)
    value1 = Enum.find(frequency1, fn {_, val} -> val == 2 end)
    key1 = String.to_integer(elem(value1, 0))
    updatedList1 = Enum.filter(list, fn(card) -> (rem(card - 1, 13) !== key1 - 1) end)
    # 2nd pair
    twoPairs2 = ignoreSuit(conversion(Enum.sort(updatedList1)))
    newList2 = Enum.map(twoPairs2, &Integer.to_string/1)
    frequency2 = Enum.frequencies(newList2)
    value2 = Enum.find(frequency2, fn {_, val} -> val == 2 end)
    key2 = String.to_integer(elem(value2, 0))
    result = Enum.filter(list, fn(card) -> (rem(card - 1, 13) == key1 - 1 || rem(card - 1, 13) == key2 - 1) end)
    conversion(result)
  end
  # twoPairs calculation
  def twoPairsScore(list) do
    twoPairs = Enum.sort(ignoreSuit(returnTwoPairs(list)))
    [ head, _, _, tail ] = twoPairs
    if (head == 1) do # special case for A
      (head + 15) * 20 + tail * 2
    else
      if (tail == 1) do # special case for A
        head * 20 + (tail + 15) * 2
      else
        head * 20 + tail * 2
      end
    end
  end

  # check if it is APair
  def isAPair(list) do
    aPair = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(aPair, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    maxFrequency = Enum.reverse(Enum.Enum.sort(Map.values(frequency)))
    [first, second | _ ] = maxFrequency
    if (first == 2 && second !== 2 )do
      true
    else
      false
    end
  end
  # return APair
  def returnAPair(list) do
    aPair = ignoreSuit(conversion(Enum.sort(list)))
    newList = Enum.map(aPair, &Integer.to_string/1)
    frequency = Enum.frequencies(newList)
    value = Enum.find(frequency, fn {_, val} -> val == 2 end)
    key = String.to_integer(elem(value, 0))
    result = Enum.filter(list, fn(card) -> (rem(card - 1, 13) == key - 1) end)
    conversion(result)
  end
  # APair calculation
  def aPairdScore(list) do
    aPair  = Enum.sort(ignoreSuit(returnAPair(list)))
    [ head | _ ] = aPair
    if (head == 1) do # special case for A
      (head + 15) * 2
    else
      head * 2
    end
  end

  # get the poker score
  def pokerScore(list) do
    cond do
    isRoyalFlush(list) ->
      10
    isStraightFlush(list) ->
      9
    isFourOfAKind(list) ->
      8
    isFullHouse(list) ->
      7
    isFlush(list) ->
      6
    isStraight(list) ->
      5
    isThreeOfAKind(list) ->
      4
    isTwoPairs(list) ->
      3
    isAPair(list) ->
      2
    end
  end

  # get the hand score
  def handScore(list) do
    cond do
    pokerScore(list) == 9 -> #StraightFlush
      straightFlushScore(list)
    pokerScore(list) == 8 -> #FourOfAKind
      fourOfAKindScore(list)
    pokerScore(list) == 7 -> #FullHouse
      fullHouseScore(list)
    pokerScore(list) == 6 -> #Flush
      flushScore(list)
    pokerScore(list) == 5 -> #Straight
      flushScore(list)
    pokerScore(list) == 4 -> #ThreeOfAKind
      threeOfAKindScore(list)
    pokerScore(list) == 3 -> #TwoPairs
      twoPairsScore(list)
    pokerScore(list) == 2 -> #APair
      aPairdScore(list)
    end
  end

  # get the winner hand
  def winnerHand(list) do
    handOne = handOne(list)
    handTwo = handTwo(list)
    if pokerScore(handOne) > pokerScore(handTwo) do
      handOne
    else
      if pokerScore(handOne) < pokerScore(handTwo) do
        handTwo
      else
        if (pokerScore(handOne) == pokerScore(handTwo) && handScore(handOne) > handScore(handTwo)) do
          handOne
          else
          handTwo
        end
      end
    end
  end

  # deal and return the winner hand
  def deal(list) do
    winner = winnerHand(list)
    cond do
      pokerScore(winner) == 10 ->
        returnFlush(winner)
      pokerScore(winner) == 9 ->
        returnStraightFlush(winner)
      pokerScore(winner) == 8 ->
        returnFourOfAKind(winner)
      pokerScore(winner) == 7 ->
        returnFullHouse(winner)
      pokerScore(winner) == 6 ->
        returnFlush(winner)
      pokerScore(winner) == 5 ->
        returnStraight(winner)
      pokerScore(winner) == 4 ->
        returnThreeOfAKind(winner)
      pokerScore(winner) == 3->
        returnTwoPairs(winner)
      pokerScore(winner) == 2 ->
        returnAPair(winner)
    end
  end
end
