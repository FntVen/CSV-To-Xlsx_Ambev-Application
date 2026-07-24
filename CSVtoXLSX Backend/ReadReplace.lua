--Read CSV in SDCard (Seected in the GUI) --> Read Relevant File for spreadsheet in the folder system --> Simplify CSV reading times from milli to minutes (average the readings too) --> For each reading one cell is written
local PathSeparator = package.config:sub(1, 1) == "\\";
local Os;
if PathSeparator then
    Os = "windows";
else
    Os = "unix"; --Apple or Linux
end

function MReader()
    local f = assert(io.open("sheet1.xml", 'rb'))
    local chunk_size = 4096
    local desc = {
        isfile = true,
        istext = true,
        isdir = false,
        mtime = os.time(),
        platform = Os,
    }
    return desc, function()
            local chunk = f:read(chunk_size)
            if chunk then return chunk end
            f:close()
        end
end

local XmlCellPath
XmlCellPath = io.open("sheet.xml", "r");
local XmlCellData
if XmlCellPath then
    XmlCellData = XmlCellPath:read("a");
    XmlCellPath:close();
else
    print("Template Excel Não Encontrado.");
    print("Por Favor Reiniciar ou Reinstalar.");
    return; -- Closes Backend
end

local CsvData = arg[1];
print(arg[1]);
print(CsvData);
if CsvPath ~= "" then
    InvalidPath = false;
    local CsvPathObject
    --if Os == "windows" then
    --    CsvPath = string.gsub(CsvPath, [[/]], [[\]]);
    --else
    --    CsvPath = string.gsub(CsvPath, [[\]], [[/]]);
    --end
    CsvPathObject = io.open(arg[1], "r");
    if CsvPathObject then
        CsvData = CsvPathObject:read("a");
        if not CsvData then
            print("CSV Invalido");
        return
        end 
    end
else
    print("Insira um Caminho.");
    return;
end

if not not (CsvData and XmlCellData) then -- Kinda dumb that for boolean comparisons for and we need to use "not not"
    local ReadingsTemp_Table = {};
    local ReadingsUmi_Table = {};
    local ReadingsTime_Table = {};
    -- Iterate through every line and then iterate through every item separated by a coma in that line
    local CurrentLine_Int = 1;
    for Line in string.gmatch(CsvData, "[^\n]+") do
        if CurrentLine_Int ~= 1 then -- Skip the header of the csv file
            local ItemCount_Int = 1;
            for Item in string.gmatch(Line, "[^,]+") do
                if ItemCount_Int == 1 then
                    table.insert(ReadingsTemp_Table, Item);
                end
                if ItemCount_Int == 2 then
                    table.insert(ReadingsUmi_Table, Item);
                end
                if ItemCount_Int == 3 then
                    table.insert(ReadingsTime_Table, Item);
                    ItemCount_Int = 1;
                end
                ItemCount_Int = ItemCount_Int + 1;
            end
        end
        CurrentLine_Int = CurrentLine_Int + 1;
    end
    
    if not not (next(ReadingsTemp_Table) and next(ReadingsUmi_Table) and next(ReadingsTime_Table)) then
        local XmlString = "<row r='_LineIterator' spans='1:3' x14ac:dyDescent='0.25'>" ..
            '<c r="A_LineIterator" s="1">' ..
            '<v>TimingReading</v>' ..
            '</c>' ..
            '<c r="B_LineIterator" s="2">' ..
            '<v>TempReading</v>' ..
            '</c>' ..
            '<c r="C_LineIterator" s="3">' ..
            '<v>UmiReading</v>' ..
            '</c>' ..
            '</row>' ..
            "ReplaceAndDelete";
        for i = 1, #ReadingsTemp_Table, 1 do -- _LineIterator will be i + 1 because the first line of the xml is already populated
            local TempString = string.gsub(XmlString, "_LineIterator", tostring(i + 1));
            TempString = string.gsub(TempString, "TempReading", ReadingsTemp_Table[i]);
            TempString = string.gsub(TempString, "UmiReading", ReadingsUmi_Table[i]);
            TempString = string.gsub(TempString, "TimingReading", ReadingsTime_Table[i]);
            XmlCellData = string.gsub(XmlCellData, "ReplaceAndDelete", TempString);
            XmlCellData = string.gsub(XmlCellData, "Replace_C", string.format("C%s",i))
        end
        XmlCellData = string.gsub(XmlCellData, "ReplaceAndDelete", "");
        local Sheet1, err;
        -- Write new file
        if Os == "windows" then
            Sheet1, err = io.open("xl\\worksheets\\sheet1.xml", "w");
        else
            Sheet1, err = io.open("xl/worksheets/sheet1.xml", "w");
        end
        if err == nil then
            Sheet1:write(XmlCellData);
            Sheet1:close();
        else
            print("Erro Na Criação de Planilha");
            return
        end
        
        -- Copy .zip and modify copy or move xl folder into uncompacted file strucute and zip it
        local ZipName = string.format("Tabela_%s.zip", tostring(os.date("%d-%m-%Y")));
        if Os == "windows" then
            local command = string.format('robocopy "%s" "%s" /E', "xl\\worksheets", "Source\\xl\\worksheets"); -- Just make sure that the terminal/frontend is on the same folder as the script
            os.execute(command);
            -- Send file into the .zip
            local CmInsertZip = string.format("Compress-Archive -Path .\\Source\\* -Update -Destination .\\%s",ZipName);
            local Status,Flav,ReturnType = os.execute(string.format('powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "%s"',CmInsertZip));
            if not Status then
                print("Por favor Atualize Seu PowerShell");
                print('Coloque esse código no seu PowerShell "winget upgrade --id Microsoft.PowerShell"')
                print('Caso o Comando Acima Não Funcione Veja o Tutorial da Microsoft "https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.6"')
                return
            end
        else
            local command = string.format('cp -rf "%s" "%s"', "LeituraTemplate.zip", ZipName);
            os.execute(command);
            -- Send file into the .zip
            local CmInsertZip = string.format("zip -u %s xl/worksheets/sheet1.xml",ZipName);
            os.execute(CmInsertZip);
        end
        os.rename(ZipName, string.gsub(ZipName, "zip", "xlsx"));
        --Last Step after debuggin is to delete the new shhet1.xml
    else
        print("Uma ou Mais Lista de Leituras Encontrada Vazia.");
        return;
    end
else
    return -- Se até com o loop anterior CsvData e XmlCellData não tiverem valores feche
end
