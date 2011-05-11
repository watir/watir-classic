Yaxin Wang/US/ThoughtWorks 
09/22/2005 02:40 PM	To
Bret Pettichord/US/ThoughtWorks@ThoughtWorks
cc

bcc

Subject
Fw: win32ole is extended
	



----- Forwarded by Yaxin Wang/US/ThoughtWorks on 09/22/2005 12:42 PM -----
Yaxin Wang/US/ThoughtWorks 
09/16/2005 04:45 PM	
To
Bret Pettichord/US/ThoughtWorks
cc
Levi Khatskevitch/US/ThoughtWorks@ThoughtWorks, Ahmed S 
Elshamy/Corporate/ThoughtWorks/US@ThoughtWorks, Ruby on Rails TWIG
Subject
win32ole is extended
	

	

I extended the win32ole to support the creation of ruby COM object from an 
IUnknown pointer.
Now we can use a win32api call to get the IUnknown pointer of a IE window 
or dialog by it's name, then we can use win32ole to wrap the IUnknown 
pointer and work on the DOM object directly.
Have a look at the test_win32ole.rb for more detail.

Yaxin

*********** changes to win32ole.c ******************

added the function fole_s_connect_unknown

/*
 * WIN32OLE.connect_unknown( pUnknown ) --> aWIN32OLE
 * ----
 * Returns running OLE Automation object or WIN32OLE object from a 
IUnknown pointer
 * the IUnknown pointer is passed in as a FIXNUM
 */
static VALUE
fole_s_connect_unknown(self, iUnknown)
    VALUE self;
    VALUE iUnknown;
{
 HRESULT hr;
 IDispatch *pDispatch;
    IUnknown *pUnknown;

 /* initialize to use OLE */
  ole_initialize();

 //cast from int to IUnknown*
 pUnknown = (IUnknown*)FIX2INT(iUnknown);

 hr = pUnknown->lpVtbl->QueryInterface(pUnknown, &IID_IDispatch,
                                              (void **)&pDispatch);
     if(FAILED(hr)) {
         OLE_RELEASE(pUnknown);
         ole_raise(hr, eWIN32OLE_RUNTIME_ERROR,
                   "Failed to connect to WIN32OLE server `%d'",
                   FIX2INT(iUnknown));
     }

 OLE_RELEASE(pUnknown);

    return create_win32ole_object(self, pDispatch, Qnil, Qnil);
}

exported the fuction fole_s_connect_unknown as connect_unknown

rb_define_singleton_method(cWIN32OLE, "connect_unknown", 
fole_s_connect_unknown, 1);

*********** changes to IEDialog.dll ******************

added the fuction GetUnknown to get the IUnknown pointer from the name of 
the window
 void GetUnknown(LPCTSTR windowName, int* pOut);


