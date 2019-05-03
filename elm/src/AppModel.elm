module AppModel exposing (ApiVersionState(..), Area, AreaGarbage, Garbage, LoadLocalStorageValue, Model, Msg(..), Region, ViewState(..))

import CommonTime exposing (DispDate, IntDate, YyyymmddDate)
import Http
import Time


type alias Model =
    { viewState : ViewState
    , errorMessage : String
    , isVersionChange : Bool
    , time : Time.Posix
    , dispDate : DispDate
    , currentDate : YyyymmddDate
    , apiVersion : String
    , areaNo : String
    , regions : List Region
    , areaGarbage : AreaGarbage
    }


type alias LoadLocalStorageValue =
    { key : String
    , value : String
    }


type alias Region =
    { regionName : String
    , areas : List Area
    }


type alias Area =
    { areaNo : String
    , areaName : String
    }


type alias AreaGarbage =
    { areaNo : String
    , areaName : String
    , garbages : List Garbage
    }


type alias Garbage =
    { garbageTitles : List String
    , garbageDates : List YyyymmddDate
    }


type Msg
    = DataError String
    | Loading
    | SetCurrentDate Time.Posix
    | LoadedLocalStorage LoadLocalStorageValue
    | LocalStorageSaved String
    | GotSavedApiVersion String
    | GotWebApiVersion (Result Http.Error String)
    | GotSavedRegions String
    | GotWebRegions (Result Http.Error String)
    | GotSavedAreaGarbage String
    | GotWebAreaGarbage (Result Http.Error String)
    | ChangeArea String
    | ViewAreaGarbage


type ViewState
    = PrepareData
    | SystemError
    | DataOk


type ApiVersionState
    = NoChange
    | RequireRegion String
    | GetError String
