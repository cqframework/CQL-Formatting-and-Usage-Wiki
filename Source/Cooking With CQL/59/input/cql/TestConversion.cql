library TestConversion

using QDM version '5.6'

context Patient

define TestConversion:
  ["Assessment, Performed"] AP
    where
      case
        when AP.result is Integer then AP.result < 2
        when AP.result is Decimal then AP.result < 2.0
        else null
      end
