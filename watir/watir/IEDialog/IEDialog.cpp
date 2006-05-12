// IEDialog.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include "IEDialog.h"

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    return TRUE;
}

 void ShowString(LPCTSTR dialogName)
 {
	 MessageBox(NULL, dialogName, "Note", MB_OK);
 }

 void DoElementClick(LPCTSTR windowName, LPCTSTR elementId)
{
	DoClick(windowName, elementId, NULL);
}

void DoButtonClick(LPCTSTR windowName, LPCTSTR buttonName)
{
	DoClick(windowName, NULL, buttonName);
}

void DoClick(LPCTSTR windowName, LPCTSTR elementId, LPCTSTR elementName)
{
	MessageBox(NULL, "Started", "Info", MB_OK);
	CoInitialize( NULL );
	
	IHTMLDocument2* pDoc2 = NULL;
	pDoc2 = GetDoc2(windowName);

	if(pDoc2 != NULL)
	{
		IHTMLElement* pElem = FindElement(pDoc2, elementId, elementName);
		if(pElem != NULL)
		{
			pElem->click();
			pElem->Release();
		}

		pDoc2->Release();
	}

	CoUninitialize();
}

void GetUnknown(HWND hWindow, int* pOut)
{
	*pOut = 0;
	
	HINSTANCE hInst = ::LoadLibrary( TEXT("OLEACC.DLL") );
	if(hInst == NULL)
	{
		 MessageBox(NULL, "Cannot load Miscrosoft Active Accessibility", "Error", MB_OK);
		 return;
	}

	HWND hWndChild=NULL;
	// Get 1st document window
	::EnumChildWindows(hWindow, EnumChildProc, (LPARAM)&hWndChild );

	IUnknown* pUnknown = NULL;

	LRESULT lRes;
	UINT nMsg = ::RegisterWindowMessage(TEXT("WM_HTML_GETOBJECT") );
	::SendMessageTimeout( hWndChild, nMsg, 0L, 0L, SMTO_ABORTIFHUNG, 1000, (DWORD*)&lRes );
	LPFNOBJECTFROMLRESULT pfObjectFromLresult = (LPFNOBJECTFROMLRESULT)::GetProcAddress( hInst, TEXT("ObjectFromLresult") );
	if ( pfObjectFromLresult != NULL )
	{
		HRESULT hr;
		hr=pfObjectFromLresult(lRes,IID_IUnknown,0,(void**)&pUnknown);

		if ( SUCCEEDED(hr) ){
			*pOut = (int)pUnknown;
		}
	}
}

IHTMLDocument2* GetDoc2(LPCTSTR windowName)
{
	HWND hWindow = ::FindWindow(NULL, windowName);
	 if(hWindow == NULL)
	 {
		 MessageBox(NULL, "Cannot find window", "Error", MB_OK);
		 return NULL;
	 }

	HINSTANCE hInst = ::LoadLibrary( TEXT("OLEACC.DLL") );
	if(hInst == NULL)
	{
		 MessageBox(NULL, "Cannot load Miscrosoft Active Accessibility", "Error", MB_OK);
		 return NULL;
	}

	HWND hWndChild=NULL;
	// Get 1st document window
	::EnumChildWindows(hWindow, EnumChildProc, (LPARAM)&hWndChild );

	IHTMLDocument2* pDoc2=NULL;

	CComPtr<IHTMLDocument> spDoc=NULL;

	LRESULT lRes;
	UINT nMsg = ::RegisterWindowMessage(TEXT("WM_HTML_GETOBJECT") );
	::SendMessageTimeout( hWndChild, nMsg, 0L, 0L, SMTO_ABORTIFHUNG, 1000, (DWORD*)&lRes );
	LPFNOBJECTFROMLRESULT pfObjectFromLresult = (LPFNOBJECTFROMLRESULT)::GetProcAddress( hInst, TEXT("ObjectFromLresult") );
	if ( pfObjectFromLresult != NULL )
	{
		HRESULT hr;
		hr=pfObjectFromLresult(lRes,IID_IHTMLDocument,0,(void**)&spDoc);

		if ( SUCCEEDED(hr) ){
			CComPtr<IDispatch> spDisp;
			CComQIPtr<IHTMLWindow2> spWin;

			hr = spDoc->get_Script( &spDisp );

			spWin = spDisp;
			spWin->get_document( &pDoc2 );
		}
	}

	return pDoc2;
}

BOOL CALLBACK EnumChildProc(HWND hwnd,LPARAM lParam)
{
	TCHAR	buf[100];

	::GetClassName( hwnd, (LPTSTR)&buf, 100 );
	if ( _tcscmp( buf, _T("Internet Explorer_Server") ) == 0 )
	{
		*(HWND*)lParam = hwnd;
		return FALSE;
	}
	else
		return TRUE;
}

IHTMLElement* FindElement(IHTMLDocument2* pDoc2, LPCTSTR elementId, LPCTSTR elementName)
{
	USES_CONVERSION;
	HRESULT hr;

	//Enumerate the HTML elements
    IHTMLElementCollection* pColl = NULL;
    hr = pDoc2->get_all( &pColl );
    if (hr == S_OK && pColl != NULL)
    {
		LONG celem;
        pColl->get_length( &celem );

		 //Loop through each elment
        for ( int i=0; i< celem; i++ )
        {
            VARIANT varIndex;
            varIndex.vt = VT_UINT;
            varIndex.lVal = i;
            VARIANT var2;
            VariantInit( &var2 );

            IDispatch* pDisp; 

            hr = pColl->item( varIndex, var2, &pDisp );//Get an element

			if ( hr == S_OK )
            {
                IHTMLElement* pElem;
				//Ask for an HTMLElemnt interface
                hr = pDisp->QueryInterface(IID_IHTMLElement, (void **)&pElem);

				if ( hr == S_OK )
                {
					if(elementId != NULL) //find element by Id
					{
						BSTR bstr;
						//Get the id of the element
						pElem->get_id(&bstr);
	                   					
						LPCTSTR id = OLE2T(bstr);

						if(_tcscmp(id, elementId))
						{
							return pElem;						
						}
					}
					else if(elementName != NULL) //find element by Name
					{
						IHTMLInputButtonElement* pButton;
                        hr = pDisp->QueryInterface(IID_IHTMLInputButtonElement,(void **)&pButton);
                        if ( hr == S_OK )
                        {
							BSTR bstr;
							//Get the name of the element
							pButton->get_name(&bstr);
		                   					
							LPCTSTR name = OLE2T(bstr);

							if(_tcscmp(name, elementName))
							{
								return pElem;						
							}
						}
					}
					
					pElem->Release();
				}
			}			
		}

		pColl->Release();
	}

	return NULL;
}


 

