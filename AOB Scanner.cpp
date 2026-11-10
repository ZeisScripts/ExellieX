#include <iostream>
#include <windows.h>
#include <tlhelp32.h>
#include <string>

// En funktion der leder efter spillets proces-ID (PID) i Windows' baggrund
DWORD GetProcessIdByName(const wchar_t* procName) {
    DWORD procId = 0;
    HANDLE hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnap != INVALID_HANDLE_VALUE) {
        PROCESSENTRY32W procEntry;
        procEntry.dwSize = sizeof(procEntry);
        if (Process32FirstW(hSnap, &procEntry)) {
            do {
                if (_wcsicmp(procEntry.szExeFile, procName) == 0) {
                    procId = procEntry.th32ProcessID;
                    break;
                }
            } while (Process32NextW(hSnap, &procEntry));
        }
    }
    CloseHandle(hSnap);
    return procId;
}

int main() {
    // 1. STIEN TIL DIN DLL:
    // HUSK AT RETTE DENNE STI, SÅ DEN PEGER PRÆCIS PÅ DIN FÆRDIGE EXE.dll!
    // Bemærk de dobbelte backslashes '\\' i stien.
    const char* dllPath = "C:\\Zeis Analytics & Solutions\\Overview\\Webhooks for BikeUniverse\\Visual Studio Stuff\\EXE.dll\\x64\\Release\\EXE.dll";

    std::cout << "=== C++ AOB Scanner ===" << std::endl;
    std::cout << "Looking for the process..." << std::endl;

    // Find spillets proces (Her skal du indtaste navnet på spillets .exe-fil)
    // Hvis du tester på Notesblok først, ændrer du det til L"notepad.exe"
    DWORD processId = GetProcessIdByName(L"RobloxPlayerBeta.exe");

    if (processId == 0) {
        std::cout << "[!] Error: Could not find the process running. Start the target first!" << std::endl;
        system("pause");
        return 1;
    }

    std::cout << "[+] Found process with ID: " << processId << std::endl;

    // TRIN 1: Åbn en dør ind til processens hukommelse
    HANDLE hProc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, processId);
    if (!hProc) {
        std::cout << "[!] Error: Could not open process (Run as administrator?)" << std::endl;
        system("pause");
        return 1;
    }

    // TRIN 2: Reserver plads i det andet programs RAM-hukommelse til stien på vores DLL
    void* allocatedMemory = VirtualAllocEx(hProc, nullptr, strlen(dllPath) + 1, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!allocatedMemory) {
        std::cout << "[!] Error: Could not reserve RAM in the process." << std::endl;
        CloseHandle(hProc);
        system("pause");
        return 1;
    }

    // TRIN 3: Skriv stien til vores DLL direkte ind i den reserverede RAM-plads
    if (!WriteProcessMemory(hProc, allocatedMemory, dllPath, strlen(dllPath) + 1, nullptr)) {
        std::cout << "[!] Error: Could not write to the process RAM." << std::endl;
        VirtualFreeEx(hProc, allocatedMemory, 0, MEM_RELEASE);
        CloseHandle(hProc);
        system("pause");
        return 1;
    }

    // TRIN 4: Tving målet til at oprette en tråd, der indlæser vores DLL via LoadLibraryA
    HANDLE hThread = CreateRemoteThread(hProc, nullptr, 0, (LPTHREAD_START_ROUTINE)LoadLibraryA, allocatedMemory, 0, nullptr);
    if (!hThread) {
        std::cout << "[!] Error: Could not force the thread to run." << std::endl;
        VirtualFreeEx(hProc, allocatedMemory, 0, MEM_RELEASE);
        CloseHandle(hProc);
        system("pause");
        return 1;
    }

    std::cout << "[+] Succes! The DLL is connected." << std::endl;

    // Ryd op efter os i hukommelsen
    WaitForSingleObject(hThread, INFINITE);
    VirtualFreeEx(hProc, allocatedMemory, 0, MEM_RELEASE);
    CloseHandle(hThread);
    CloseHandle(hProc);

    std::cout << "[+] Injection is done!" << std::endl;
    system("pause");
    return 0;
}
