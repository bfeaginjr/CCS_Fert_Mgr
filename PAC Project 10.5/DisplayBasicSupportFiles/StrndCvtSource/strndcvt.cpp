/*====================================================================
/
/  File Name    : STRNDCVT.CPP
/  Expanded Name: SuperTrend File Conversion Utility
/
/  Description  : Utility program convert SuperTrend Historic trend
/                 files from  text to binary, or binary to text
/
/  NOTE         : This code is provided by Opto 22 for modification by
/                 the user. Opto 22 assumes no responsibility for its
/                 use.
====================================================================*/

#ifndef __WINDOWS_H
  #include <windows.h>
#endif

#ifndef __STDIO_H
 #include <stdio.h>
#endif


// global structure for writing/reading point data as binary.
struct STPointData
{
  char     cFmt;        // Date format
  char     cPenId;      // the pen ID
  FILETIME ftDateTime;  // date and time of point data
  float    fPointVal;   // value of point data
  char     szCRLF[2];   // placeholder for the CRLF added to each line
  STPointData();        // constructor
};



// Constructor for the STPointData structure
STPointData::STPointData()
{
  cFmt = 'U';
  cPenId = 0;
  fPointVal = 0.0;
  ftDateTime.dwLowDateTime = (DWORD)0;
  ftDateTime.dwHighDateTime = (DWORD)0;
  szCRLF[0] = '\r';
  szCRLF[1] = '\n';
  // note we don't need terminating NULL, since we'll be writing out
  // the structure as a whole.
}



// -------------------------------------------------------------------
// Check to see if the file from the command line is a text file or a
// binary
// -------------------------------------------------------------------
bool IsTextFile(char *szFile)
{
  FILE *f = fopen(szFile, "rb");

  // if we can't open file, display a warning message and quit
  if (!f)
  {
    char szMsg [255];
    wsprintf(szMsg, "Unable to open file %s", szFile);
    MessageBox(NULL, szMsg, "File open error", MB_OK |
               MB_ICONEXCLAMATION);
    exit(-1);
  }

  // buffer to hold the 1st 15 bytes. If this is a binary file, byte
  // 15 will be a CR ('\r')
  char szFirst15[16];

  // read in the first 15 bytes!
  fread((void *)szFirst15, 15, 1, f);
  szFirst15[15] = 0;
  fclose(f);

  // if byte 15 != CR, return true - it's a text file
  return (bool)(szFirst15[14] != '\r');
}



//--------------------------------------------------------------------
// Gets the Date format the file was stored in.  The second line of
// the text file is either //U for MM/DD/YYY format,
// or //N for DD/MM/YYYY format
// Note: we're passed in an already open FILE stream
//--------------------------------------------------------------------
char GetDateFormat(FILE *pFile)
{
  char szBuff [80];

  // get first line
  fgets(szBuff, 80, pFile);

  // toss it and get second line
  fgets(szBuff, 80, pFile);

  // reset file pointer
  rewind(pFile);

  return szBuff [2];
}



//--------------------------------------------------------------------
//  This reads the text file line by line until it gets to the first
//  text entry.  Each  line of the header will begin with either a '/'
//  character, or a '\r'.  The text enties will start with a  number
//  (the pen id).  We're passed in an already opened file stream
//--------------------------------------------------------------------
void FindFirstTextEntry(FILE *pFile)
{
  char szBuff[256];
  fpos_t fpos;

  // get the current file poistion
  fgetpos(pFile, &fpos);

  // read in first line
  do
  {
    *szBuff = 0;
    // get the file pointer for this line so we can reset it when
    //we've  got the correct line
    fgetpos(pFile, &fpos);
    fgets(szBuff, 255, pFile);
    if  (!*szBuff)
      break;
  } while (*szBuff == '/' || *szBuff == '\r');

  // we've gone to far, reset the file position to beginning of line
  fsetpos(pFile, &fpos);
}



// -------------------------------------------------------------------
// Read in the text version of the SuperTrend historic file, and
// create a binary version.  Appends a ".bin" to the original file
// name
// -------------------------------------------------------------------
void ConvertTextToBinary(char *szFile)
{
  int         nPen;
  FILE        *pFileIn, *pFileOut;
  SYSTEMTIME  stTime;
  char        *szNewFileName;
  char        cFmt;
  STPointData stPointData;


  // create the output file with the extension .bin
  szNewFileName = new char [strlen(szFile) + 5];
  strcpy(szNewFileName, szFile);
  strcat(szNewFileName, ".bin");


  // open our input and output files. Note - we've already tested that
  // fopen works in the IsTextFile() function
  pFileIn = fopen(szFile, "rb");

  // get the date format
  cFmt = GetDateFormat(pFileIn);

  // open output file
  pFileOut = fopen(szNewFileName, "wb");

  if (!pFileOut)
  {
    char szMsg [255];
    wsprintf(szMsg, "Unable to open output file %s", szNewFileName);

    MessageBox(NULL, szMsg, "File open error", MB_OK |
               MB_ICONEXCLAMATION);

    // clean up
    fclose(pFileIn);

    delete [] szNewFileName;

    return;
  }

  // we need to go past the header info
  FindFirstTextEntry(pFileIn);

  // read in text data; write binary data
  while (fscanf(pFileIn, "%d %hd/%hd/%hd %hd:%hd:%hd.%hd%f", &nPen,
                        cFmt == 'U' ?  &(stTime.wMonth) :
                                       &(stTime.wDay),
                        cFmt == 'U' ?  &(stTime.wDay)   :
                                       &(stTime.wMonth),
                        &(stTime.wYear),
                        &(stTime.wHour), &(stTime.wMinute),
                        &(stTime.wSecond), &(stTime.wMilliseconds),
                        &(stPointData.fPointVal))
         == 9)
  {
    // set our structure data members
    stPointData.cFmt = cFmt;
    stPointData.cPenId    = (char)nPen;
    SystemTimeToFileTime(&stTime, &stPointData.ftDateTime);

    // write binary data to file
    fwrite((void *)&stPointData, sizeof(stPointData), 1, pFileOut);
  }

  // all done, so close files
  fclose(pFileIn);
  fclose(pFileOut);

  // clean up our memory allocation
  delete [] szNewFileName;
}



// -------------------------------------------------------------------
// Read in the binary version of the SuperTrend historic file, and
// create a text version. Appends a ".txt" to the original file name
// -------------------------------------------------------------------
void ConvertBinaryToText(char *szFile)
{
  FILE        *pFileIn, *pFileOut;
  SYSTEMTIME  stTime;
  char        *szNewFileName;
  STPointData stPointData;
  char        szFormatString [40];
  bool        bWroteHeader = false;

  // create the output file with the extension .txt
  szNewFileName = new char [strlen(szFile) + 5];
  strcpy(szNewFileName, szFile);
  strcat(szNewFileName, ".txt");


  // open our input and output files. Note - we've already tested that
  // fopen  works in the IsTextFile() function
  pFileIn = fopen(szFile, "rb");
  pFileOut = fopen(szNewFileName, "wb");

  if (!pFileOut)
  {
    char szMsg [255];
    wsprintf(szMsg, "Unable to open output file %s", szNewFileName);

    MessageBox(NULL, szMsg, "File open error", MB_OK |
               MB_ICONEXCLAMATION);

    // clean up
    fclose(pFileIn);

    delete [] szNewFileName;

    return;
  }


  // read in our binary data; write out text data
  while (fread((void *)&stPointData, sizeof(stPointData), 1, pFileIn)
          == 1)
  {
    // convert our time
    FileTimeToSystemTime(&stPointData.ftDateTime, &stTime);

    // format our string
    sprintf(szFormatString, "%d %02d/%02d/%d %02d:%02d:%02d.%03d %f",
            (int)stPointData.cPenId,
            stPointData.cFmt == 'U' ? stTime.wMonth : stTime.wDay,
            stPointData.cFmt == 'U' ? stTime.wDay   : stTime.wMonth,
            stTime.wYear,
            stTime.wHour, stTime.wMinute, stTime.wSecond,
            stTime.wMilliseconds, stPointData.fPointVal);

    // the first time we need to write a header for future
    // conversions. But  only do this the first time!
    if (false == bWroteHeader)
    {
      fprintf(pFileOut, "//\r\n//%c\r\n", stPointData.cFmt);
      bWroteHeader = true;
    }

    // write it out to file
    fprintf(pFileOut, "%s\r\n", szFormatString);
  }

  // all done, so close files
  fclose(pFileIn);
  fclose(pFileOut);

  // clean up our memory allocation
  delete [] szNewFileName;
}



// -------------------------------------------------------------------
// The Main() function
// -------------------------------------------------------------------
int main (int argc, char **argv)
{
  // make sure only one file entered on command line
  if (argc != 2)
  {
    MessageBox(NULL, "Format: Strndcvt <filename>", NULL, MB_OK);
    return -1;
  }

  // see if this is a text or binary file
  bool bIsTextFile = IsTextFile(argv[1]);

  // act accordingly
  if (bIsTextFile)
  {
    ConvertTextToBinary(argv[1]);
  }
  else
  {
    ConvertBinaryToText(argv[1]);
  }

  return 0;
}
