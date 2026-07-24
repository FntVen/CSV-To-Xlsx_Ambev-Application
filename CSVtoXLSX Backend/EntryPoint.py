import os
import subprocess
from tkinter import filedialog
import psutil
import customtkinter as ctk
from pathlib import Path

def DiskSelect(Index):
    SelectedDisk = DiskList[Index-1]
    CSVFile = filedialog.askopenfilename(initialdir=SelectedDisk)
    if CSVFile != "" and CSVFile.__contains__(".csv"):
        CSVFile = CSVFile.replace(r"/", "\\")
        print(CSVFile)
        ExcelPath = subprocess.run(["lua", "ReadReplace.lua ", CSVFile])
        print(CSVFile)
class App(ctk.CTk):
     def __init__(self):
         super().__init__()
         #Tela Base
         self.title("Conversor Para Excel")
         self.geometry("900x600")
         self.columnconfigure(0, weight=1)
         self.rowconfigure(0, weight=1)
         #Tela de Foco
         self.Picture = ctk.CTkFrame(self,width=850,height= 550)
         self.Picture.grid(row=0, column=0, padx=25, pady=25, sticky="nsew")
         self.Picture.rowconfigure(1, weight=1)
         self.Picture.columnconfigure(0, weight=1)
         self.Instru = ctk.CTkLabel(self.Picture, text="Selecione Disco Representante do Cartão SD", font=ctk.CTkFont(size=24))
         self.Instru.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")
         #Lista de Discos
         self.DiscFrame = ctk.CTkFrame(self.Picture,width=800,height= 100)
         self.DiscFrame.grid(row=1, column=0, padx=10, pady=10, sticky="nsew")
         BtnCounter = 0
         for DiskPath in DiskList:
             self.Btn = ctk.CTkButton(self.DiscFrame, width= 790, height= 95,fg_color="#B2BEB5",text=DiskPath, font=ctk.CTkFont(size=24),text_color="black",hover_color="#D3D3D3",command=lambda i=BtnCounter: DiskSelect(BtnCounter))
             self.Btn.grid(row=BtnCounter, column=0, padx=10, pady=10, sticky="nsew")
             self.DiscFrame.columnconfigure(BtnCounter, weight=1)
             BtnCounter += 1


DiskPart = psutil.disk_partitions(False)
DiskList = []
for Disk in DiskPart:
    DiskList.append(Disk.mountpoint)
Instancia = App()
Instancia.mainloop()