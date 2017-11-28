
(gwmi -ComputerName dkhqexc04n01 -Class win32_processor | select deviceid) | Measure-Object | Select count





