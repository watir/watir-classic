require 'thread'

module Borges

  VERSION = "1.0.0-alpha3"

  class Controller; end
  class Component < Controller; end
  class Counter < Component; end

end

require 'Borges/Extensions/Array'
require 'Borges/Extensions/Numeric'
require 'Borges/Extensions/Object'
require 'Borges/Extensions/Proc'
require 'Borges/Extensions/String'

require 'Borges/Utilities/ExternalID'
require 'Borges/Utilities/LRUCache'
require 'Borges/Utilities/RenderNotification'
require 'Borges/Utilities/Request'
require 'Borges/Utilities/Response'
require 'Borges/Utilities/SimulatedRequestNotification'
require 'Borges/Utilities/WeakIdentityKeyHash'
require 'Borges/Utilities/StateHolder'
require 'Borges/Utilities/StateRegistry'

require 'Borges/HTML/RenderingContext'
require 'Borges/HTML/HtmlAttributes'
require 'Borges/HTML/HtmlElement'
require 'Borges/HTML/HtmlBuilder'
require 'Borges/HTML/HtmlRenderer'
require 'Borges/HTML/PluggableSelectBox'

require 'Borges/RequestHandler/RequestHandler'
require 'Borges/RequestHandler/Registry'
require 'Borges/RequestHandler/Application'
require 'Borges/RequestHandler/Dispatcher'
require 'Borges/RequestHandler/DocumentHandler'
require 'Borges/RequestHandler/NotFoundHandler'
require 'Borges/RequestHandler/Session'

require 'Borges/Session/ControllerSession'
require 'Borges/Session/AuthenticatedSession'

require 'Borges/Response/BasicAuthResponse'
require 'Borges/Response/GenericResponse'
require 'Borges/Response/HtmlResponse'
require 'Borges/Response/NotFoundResponse'
require 'Borges/Response/RedirectResponse'
require 'Borges/Response/RefreshResponse'

require 'Borges/Callback/Callback'
require 'Borges/Callback/ActionCallback'
require 'Borges/Callback/CallbackStore'
require 'Borges/Callback/DispatchCallback'
require 'Borges/Callback/ValueCallback'

require 'Borges/Preference/Preferences'
require 'Borges/Preference/Preference'
require 'Borges/Preference/BooleanPreference'
require 'Borges/Preference/ListPreference'
require 'Borges/Preference/NumberPreference'
require 'Borges/Preference/StringPreference'

require 'Borges/ErrorPage/ErrorPage'
require 'Borges/ErrorPage/EmailErrorPage'
require 'Borges/ErrorPage/WalkbackPage'

require 'Borges/Filter/Filter'
require 'Borges/Filter/BasicAuthentication'
require 'Borges/Filter/Once'
require 'Borges/Filter/Transaction'

require 'Borges/Controller/Controller'
require 'Borges/Controller/Component'
require 'Borges/Controller/Task'

require 'Borges/Component/ApplicationEditor'
require 'Borges/Component/ApplicationList'
require 'Borges/Component/BatchedList'
require 'Borges/Component/ComponentTree'
require 'Borges/Component/Counter'
require 'Borges/Component/DateRangeSelector'
require 'Borges/Component/DateSelector'
require 'Borges/Component/DateTable'
require 'Borges/Component/NavigationBar'
require 'Borges/Component/Path'
require 'Borges/Component/Report'
require 'Borges/Component/SelectionDateTable'
require 'Borges/Component/TabPanel'
require 'Borges/Component/TaskFrame'
require 'Borges/Component/ToolFrame'
require 'Borges/Component/Window'
require 'Borges/Component/Dialog/Dialog'
require 'Borges/Component/Dialog/InputDialog'
require 'Borges/Component/Dialog/RadioDialog'

# TODO These still require some work
#require 'Borges/Component/ExampleBrowser'
#require 'Borges/Component/GeeWeb'
#require 'Borges/Component/Tutorial'

require 'Borges/Report/ReportColumn'
require 'Borges/Report/TableReport'

require 'Borges/Task/PluggableTask'
require 'Borges/Task/Tool'

