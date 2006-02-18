extern "C" _declspec(dllexport) void ShowString(LPCTSTR dialogName);

extern "C" _declspec(dllexport) void DoElementClick(LPCTSTR windowName, LPCTSTR elementName);

extern "C" _declspec(dllexport) void DoButtonClick(LPCTSTR windowName, LPCTSTR buttonName);

extern "C" _declspec(dllexport) void GetUnknown(HWND hWindow, int* pOut);

void DoClick(LPCTSTR windowName, LPCTSTR elementId, LPCTSTR elementName);

BOOL CALLBACK EnumChildProc(HWND hwnd,LPARAM lParam);

IHTMLDocument2* GetDoc2(LPCTSTR windowName);

IHTMLElement* FindElement(IHTMLDocument2* pDoc2, LPCTSTR elementId, LPCTSTR elementName);