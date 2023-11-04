#ifndef STDIMPL_H
#define STDIMPL_H

#include <chrono>
#include <string>
#include <vector>

namespace StdImpl {

#ifdef _WIN32
    using TChar = wchar_t;
    using TString = std::wstring;

#  define _TSTR(X) L##X
#  define _FOPEN   _wfopen
#else
    using TChar = char;
    using TString = std::string;

#  define _TSTR(X) X
#  define _FOPEN   fopen
#endif

    using TStringList = std::vector<TString>;

    void tprintf(const TChar *format, ...);

    int tstrcmp(const TChar *s, const TChar *p);

    inline int tstrcmp(const TString &s, const TChar *p) {
        return tstrcmp(s.data(), p);
    }

    std::string toHexString(const std::vector<uint8_t> &data);

    std::vector<uint8_t> fromHexString(const std::string &str);

    template <class T>
    std::vector<std::basic_string<T>> split(const std::basic_string<T> &s,
                                            const std::basic_string<T> &delimiter) {
        std::vector<std::basic_string<T>> tokens;
        typename std::basic_string<T>::size_type start = 0;
        typename std::basic_string<T>::size_type end = s.find(delimiter);
        while (end != std::basic_string<T>::npos) {
            tokens.push_back(s.substr(start, end - start));
            start = end + delimiter.size();
            end = s.find(delimiter, start);
        }
        tokens.push_back(s.substr(start));
        return tokens;
    }

    struct FileTime {
        std::chrono::system_clock::time_point accessTime;
        std::chrono::system_clock::time_point modifyTime;
        std::chrono::system_clock::time_point statusChangeTime; // Creation time on Windows
    };

    FileTime fileTime(const TString &path);

    bool setFileTime(const TString &path, const FileTime &times);

    inline bool syncFileTime(const TString &dest, const TString &src) {
        return setFileTime(dest, fileTime(src));
    }

}

#endif // STDIMPL_H
