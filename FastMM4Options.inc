{

Fast Memory Manager: ѡ�������ļ�

������ΪFastMM����Ĭ��ѡ��

FastMM 4.97

}

{
   Simplified Chinese translation by QianYuan Wang

   Contact me if you find any improper translation.
   ������������κβ�ǡ���ĵط��������ϵ��

   E-Mail: wqyfavor@qq.com
}

{
 �Ը�����ѡ��ķ��루���������
 
 Align16Bytes 					��16�ֽڶ���
 UseCustomFixedSizeMoveRoutines 		ʹ�ù̶��ߴ��ڴ��ƶ�����
 UseCustomVariableSizeMoveRoutines 		ʹ�ÿɱ�ߴ��ڴ��ƶ�����
 AssumeMultiThreaded 				�����̴߳���
 NeverSleepOnThreadContention 			�̳߳�ͻʱ����ͣ����
 InstallOnlyIfRunningInIDE 			����Delphi���������м����ڴ������
 NeverUninstall 				��ж��FastMM
 UseRuntimePackages 				ʹ�������ڰ�
 
 NoDebugInfo 					�޵�����Ϣ
 NoMessageBoxes 				����ʾ��Ϣ
 UseOutputDebugString 				ʹ��Windows API OutputDebugString
 ASMVersion 					���汾
 CheckHeapForCorruption 			���Ѵ���
 DetectMMOperationsAfterUninstall 		����ڹ�����ж�غ��������ò���
 FullDebugMode 					ȫ����ģʽ
   RawStackTraces 				���׵�ջ׷��
   CatchUseOfFreedInterfaces 			��׽�������ٶ��������
   LogErrorsToFile 				��¼�����ļ�
   LogMemoryLeakDetailToFile 			��¼�ڴ�й¶ϸ�ڵ��ļ�
   ClearLogFileOnStartup 			����ʱ�����־�ļ�
   LoadDebugDLLDynamically 			��̬���ص���Dll
   AlwaysAllocateTopDown 			�ܴ���˷����ڴ�

 EnableMemoryLeakReporting 			�����ڴ�й¶����
   HideExpectedLeaksRegisteredByPointer 	������ָ���¼�Ŀ��ܵ��ڴ�й¶
   RequireIDEPresenceForLeakReporting 		����IDE����ʱ����й¶����
   RequireDebuggerPresenceForLeakReporting 	���ڵ���������ʱ����й¶����
   RequireDebugInfoForLeakReporting 		й¶������Ҫ������Ϣ
   ManualLeakReportingControl 			�ֹ�����й¶����
   HideMemoryLeakHintMessage 			�����ڴ�й¶��ʾ��Ϣ

 EnableMMX 					����ʹ��MMX
   ForceMMX 					ǿ��ʹ��MMX

 ShareMM 					�����ڴ������
   ShareMMIfLibrary 				������Dll�й����ڴ������
 AttemptToUseSharedMM 				���Թ����ڴ������
 EnableBackwardCompatibleMMSharing 		���������ݵ��ڴ����������

 FullDebugModeInIDE 				��Delphi���������н���ȫ����
}

{--------------------------- �ۺ�ѡ�� -----------------------------}

{������ѡ��Ὣ�����ڴ�鰴16�ֽڶ����Ա�SSEָ����԰�ȫʹ�á������ѡ��رգ�һЩ
 ��С���ڴ��ᰴ8�ֽڷ�ʽ���룬�⽫�����ڴ�ʹ�á������Ƿ�����ѡ��еȺʹ����
 ��鶼������16�ֽڷ�ʽ���롣}
{.$define Align16Bytes}

{����������С�ڴ��ʱʹ�ø���Ķ��ߴ��ڴ��ƶ���������Ϊ��Щ���������Ϊ�ƶ��̶��ߴ�
 �ڴ棬����Ч�ʴ������Borland��RTL�е��ڴ��ƶ���������һѡ�����FastMove�����ʹ��
 ���ﵽ���ߵ�Ч�ʡ�}
{$define UseCustomFixedSizeMoveRoutines}

{������ѡ����ʹ���Ż��ĺ������ƶ������С���ڴ�顣ʹ��Fastcode��FastMove����ʱ����
 ��ѡ�ʹ��FastMove�������ʹ��������ʹ�õ�������ڴ��ƶ����������������ڴ����
 ������˽��齫FastMM��FastMove�������ϣ����رմ�ѡ�}
{$define UseCustomVariableSizeMoveRoutines}

{������ѡ���ʹ�������Delphi IDE������ʱ�żӲ�FastMM��Ϊ�ڴ������������ϣ��������
 Exe��������Ե�Exe����ֻϣ���ڿ���������ʹ�õ���ʱ�뿪����ѡ�������������ֲ���
 �ڿ������������У�����ʹ��Ĭ�ϵ�Delphi�ڴ����������Delphi2006�Ժ��ǲ�����FullDebugMode
 ��FastMM��}
{.$define InstallOnlyIfRunningInIDE}

{����QC#14070��Delphi������borlandmm.dll�Ĺر�ָ��ִ�к��ͷ��ڴ棩����ʹ����FastMM
 Ϊ���ĵ�borlandmm.dll�����Ʒ��FastMM���ܱ�����ж�ء�������ѡ��᲻ж���ڴ������
 ���ܿ��������}
{.$define NeverUninstall}

{����ڵ�ǰ������ʹ���������ڵİ�����Ҫ�������ѡ����Զ�����AssumeMultiThreaded��
 ע�������ȷ��������ָ�붼�ͷź�FastMM��ж�ء��������ô�������һ���кܶ�A/V�ľ�
 ����ڴ�й¶���档���ο��������⣩�����ͬʱ������ѡ���NeverUninstallѡ�}
{.$define UseRuntimePackages}

{-----------------------Concurrency Management Options------------------------}

{������Ĭ�ϳ����Ƕ��̵߳ģ����ᵼ�µ��̳߳����ٶ������½�����ʹ�ÿ���δ��ȷ��
 ��IsMultiThread�����Ķ��̵߳ĵ���������ʱ�뿪����ѡ��ڵ��߳�������Ͷ��߳�Dll
 �乲���ڴ������ʱҲ�迪����}
{.$define AssumeMultiThreaded}

{������ѡ��������̳߳�ͻʱ��һ���߳���ͣ���ڻ������CPU������Ŀ�ȵͣ�С��2��ʱ
 ���������ٶȡ������󣬳�ͻʱһ���߳̽�����롰�ȴ���ѭ�������ǽ���ʱ��Ƭ��}
{.$define NeverSleepOnThreadContention}

  {�����󣬵��̳߳�ͻʱ�����SwitchToThread������һֱͣ���ڡ��ȴ���ѭ���С����ѡ����Ҫ
   ���NeverSleepOnThreadContentionһ��ʹ�ã����ұ�����ǰ�߿���ʱ����Ч����ϵͳ�ж��
   CPU���Ļ��߳��в�ͬ�����ȼ�ʱ��������ѡ������Ч�ʡ�SwitchToThread����ֻ��Windows2000
   ���Ժ�汾��Ч��}
  {.$define UseSwitchToThread}

{----------------------------- ����ѡ�� -------------------------------}

{������ѡ�����ΪFastMM4.pas��Ԫ�������Դ��룬Ҳ��ͬʱ��ֹ����������FastMM4.pas��Ԫ}
{.$define NoDebugInfo}

{��������ѡ�����ʾ�κ���Ϣ���ڲ�����ֹ�ķ����������бȽ�����}
{.$define NoMessageBoxes}

{���Ҫʹ��Windows API OutputDebugString��������ʾ������Ϣ�뿪������ѡ��}
{.$define UseOutputDebugString}

{������ѡ���ʹ�û�����԰汾��FastMM�����Pascal�汾��Ҫ�졣���ڵ���ʱ�رմ�ѡ�
 ����CheckHeapForCorruption���Զ��رմ�����}
{$define ASMVersion}

{FastMM�ܻᲶ׽�������ͷŵ�ͬһ�ڴ����������������Ҳ���Լ��ѵĴ���ͨ������
�ڳ���Խ���д�ڴ棩����Щ���ܺķ�ʱ�䣬�������ѡ��Ӧ��������ʱʹ�á������ѡ��
������ASMVersion���Զ��ر�}
{.$define CheckHeapForCorruption}

{������ѡ�������FastMM��ж�غ���û���FastMM�����ò����������󣬵�FastMM��ж�أ�
 ����������������ǰ���ڴ�����������Ǽ������һ���ڴ������������һ�����ڴ������
 �׳�������Ჶ׽����FastMM�ѱ�ж�ض������Խ����ڴ�����Ĵ���}
{$define DetectMMOperationsAfterUninstall}

{��������ѡ�������ڴ�й¶���й㷺��⡣�����ڴ�鶼�����ÿ��׺͸�������У��ѵ���
 ���ԡ��ͷŵ��ڴ�飨ָ�룩Ҳ�ᱻ����Ա�֤���ǲ��ᱻ�ٴ�ʹ�á���һѡ������Ƚ�
 ���ڴ�����ٶȣ���������һ����Խ���д�ڴ���ظ�ʹ���ѱ��ͷŵ�ָ��ĳ���ʱ��ʹ�á�
 ������ѡ�������Զ�����CheckHeapForCorruption���Զ��ر�ASMVersion����ʾ��������
 ��ѡ��ʱ��������Ҫʹ��FastMM_FullDebugMode.dll�ļ���������ļ���ʧ�������޷�������}
{.$define FullDebugMode}

  {������ѡ���Խ��г��׵�ջ׷�٣��������ջ��Ŀ��Ѱ�ҺϷ��ķ��ص�ַ��ע�����ʹ��
   ��ջ֡�ķ���Ҫ���ܶ࣬�������ס���������FullDebugModeʱ��ѡ����Ч��}
  {$define RawStackTraces}

  {������ѡ���������ж������ٶ�������á�ע�����ʹ�����ͷŶ����޸Ĺ������ݱ�
   ���ǣ����ڴ��ļ���޷����У������޷����棩����������FullDebugModeʱ��ѡ����Ч��}
  {.$define CatchUseOfFreedInterfaces}

  {������ѡ���Լ�¼���еĴ���һ�������ͬĿ¼���ı��ļ��С��ڴ������󣨵�����
   FullDebugMode���������ӵ������־����FullDebugMode�رգ���ѡ����Ч}
  {$define LogErrorsToFile}

  {������ѡ����¼����й¶��һ�������ͬĿ¼���ı��ļ��С��ڴ�й¶���棨������
   FullDebugMode���������ӵ������־����"LogErrorsToFile"��"FullDebugMode"δ��
   ����ѡ����Ч��ע��ͨ������й¶���ᱻ��¼��������ЩAddExpectedMemoryLeaks��ʶ��
   ���ܵ��ڴ�й¶����Щ��ָ������Ŀ��ܵ�й¶���ܻ����ڿ���HideExpectedLeaks-
   RegisteredByPointer������ʾ��}
  {$define LogMemoryLeakDetailToFile}

  {��������ʱɾ����־�ļ�����LogErrorsToFile������ʱ��Ч}
  {.$define ClearLogFileOnStartup}

  {�Ƿ�̬����FASTMM_FullDebugMode.dll������Ҳ�����Dll��ջ׷�ٽ��޷����С�ע��
   �������ڴ������ʱ����Dllж��˳��ı䣬���ܻᷢ������}
  {.$define LoadDebugDLLDynamically}

    {.$define DoNotInstallIfDLLMissing}
    {������ѡ��󣬲��ҿ���FullDebugMode��LoadDebugDLLDynamicallyʱ�����
     FastMM_FullDebugMode.dll�ļ���ʧ����ôFastMM��������ء�}

  {FastMMͨ����ʹ����˵Ŀ��õ�ַ���������ڴ�飬������Ͷ˵Ŀ��õ�ַ�Ϸ���
   �С�С�ڴ�飨����һ���̶��ϼ�����Ƭ����������ѡ���ʹ�ڴ����������ʹ���
   �˵Ŀ��õ�ַ���������ʹ���˴���2GB���ڴ沢���㷨��������ָ����� �����ѡ
   ���������緢�ִ���}
  {$define AlwaysAllocateTopDown}

  {�����󽫲�����ڴ�ת��������־��¼��������¼������}
  {.$define DisableLoggingOfMemoryDumps}

  {FullDebugModeģʽ�£���FreeMem����ʧ��ʱͨ���᷵��һ����ָ�������Ч����
   ���������ʱ��һ���쳣���ڱ������������ڡ�try..finally���У�����ԭ�ȵ��쳣�ͻᶪʧ��
   ������ѡ��������ʱ���б���쳣����������ôFastMM������FreeMem�з�������}
  {$define SuppressFreeMemErrorsInsideException}

{--------------------------- �ڴ�й¶���� -----------------------------}

{������ѡ���������ڴ�й¶���棬����������ѡ�����ʹ�á�}
{$define EnableMemoryLeakReporting}

  {��������ѡ�������ʾ�ͼ�¼��ָ�����͵��µĿ��ܵ��ڴ�й¶�����ָࣨ�룩����
   �Ŀ��ܵ��ڴ�й¶��������ȷ��������Щ���ܵ�й¶���ǻ��¼����־����FullDebugMode
   ��LogMemoryLeakDetailToFile����ʱ�����ҵ�ʵ��й¶���ڴ��Ķ�ʱһ������ʾ��}
  {$define HideExpectedLeaksRegisteredByPointer}

  {��������ѡ����ʵ�ֽ���Delphi�������ϴ���ʱ�ű����ڴ�й¶����"EnableMemoryLeakReporting"
   �ر�ʱ��ѡ����Ч��}
  {.$define RequireIDEPresenceForLeakReporting}

  {��������ѡ����ʵ�ֽ���Delphi�е��Գ���ʱ�ű����ڴ�й¶����"EnableMemoryLeakReporting"
   �ر�ʱ��ѡ����Ч����ѡ����ڵ���EXE����ʱ��Ч����֧��Dll}
  {$define RequireDebuggerPresenceForLeakReporting}

  {��������ѡ����ʵ�ֽ��ڱ����뵥Ԫ�д��ڵ���ָʾ����$D��ʱ�Ž���й¶��⡣��
   "EnableMemoryLeakReporting"�ر�ʱ��ѡ����Ч��}
  {.$define RequireDebugInfoForLeakReporting}

  {������ѡ�����ֹ������ڴ�й¶���档������ʱ��ReportMemoryLeaksOnShutdown������
   �ر�ʱ�����ڴ�й¶��Ĭ�Ϲرգ����Ϊѡ���Ƿ����ɱ��档����ʱ������й¶���ѡ��
   Ҳ������ȷ���ò��ܽ��м��}
  {.$define ManualLeakReportingControl}

  {��������ѡ�����ʾ�ڴ�й¶��Ϣ�������ʾ��}
  {.$define HideMemoryLeakHintMessage}

{-------------------------- ָ����� ----------------------------}

{��������ѡ����ʹ��MMXָ����رմ�ѡ��ᵼ��������΢�½���������AMD K5��
 Pentium I�����ڴ��������ּ��ݡ�ĿǰMMXָ��ֻ�ڿɱ�ߴ���ڴ��ƶ���ʹ�ã�������
 ��UseCustomVariableSizeMoveRoutines�رգ���ѡ����Ч��}
{.$define EnableMMX}

  {��������ѡ����ǿ��ʹ��MMXָ���������CPU�Ƿ�֧�֡������һѡ��رգ�
   �������ȼ��CPU�Ƿ�֧��MMXָ���EnabledMMX�ر�ʱ��Ч��}
  {$define ForceMMX}

{----------------------- �����ڴ���������� ------------------------}

{������ͬʹ��FastMM������������Dll֮�乲���ڴ���������������Dll�еĺ�������
 ��̬����ͳ��ַ�������Ҫ����Dllʱ����AttemptToUseSharedMM�ſ�������ʵ���ڴ湲����
 ע������������ǵ��̶߳�Dll�Ƕ��̵߳ģ���������������￪��IsMultiThread,������
 �̳߳�ͻʱ����������ע�⾲̬���ӵ�Dll����������֮ǰ��ʼ��������������ʵ�ʻ���
 Dll�����ڴ��������
}
{.$define ShareMM}

  {����Dll֮�䣨��̬����Dllʱ��������֮�䣩�����ڴ������,Ҫ��ͬʹ��FastMM���롣
   ��ʹ�ö�̬���ӵ�Dllʱ��Ҫע�⣬��Ϊ���Dll��ж�ض�����Dll���ڹ����ڴ����������
   �򽫻���������ѡ��ֻ��Dll����ض�����ҪShareMM��AttemptToUseSharedMM������ע��
   ���Dll�Ǿ�̬���ӵģ����ǻ���������֮ǰ��ʼ����ʵ���������������ǹ�������������
   ShareMM�ر�ʱ��ѡ����Ч} 
  {.$define ShareMMIfLibrary}

{��������ѡ��᳢�������������֮��ͬ�����Dll��Ҳ������ѡ�֮�乲���ڴ����
 ����������ʱ����ʹ�ù����߲�����й¶�������Զ���������ھ�̬���ӵ�Dll����������
 ֮ǰ��ʼ���ģ����Ը���������ù���ѡ��}
{.$define AttemptToUseSharedMM}

{�����������ѡ���Ա�֤�ڴ���������������ԡ���Delphi2006��Delphi2007���ϰ汾
FastMM��Ч}
{$define EnableBackwardCompatibleMMSharing}

{-------------------------------- ������� ------------------------------}

{������ѡ�����FullDebugMode��InstallOnlyIfRunningInIDE��LoadDebugDLLDynamically��
 �����������Delphi�н��е������У�FastMM���������ȫ���ԣ�����FullDebugMode��������
 ��ʹ��Ĭ���ڴ��������Delphi2006�汾�Ժ���δ����FullDebugMode��FastMM����}
{$define FullDebugModeInIDE}

{��ѡ�����FullDebugMode��LoadDebugDLLDynamically��DoNotInstallIfDLLMissingһ��
 ʹ�á������������FastMM_FullDebugMode.dll�ļ����ҿ�����FullDebugMode��ô������ȫ
 ����ģʽ���������ڷ�����exe�͵��Ե�exe������ͬһ���ļ�������ʱֻҪȥ��FastMM_FullDebugMode.dll
 �ļ��Ϳ����ˡ�}
{.$define FullDebugModeWhenDLLAvailable}

{�������÷����汾�͵��԰汾}
{$ifdef Release}
  {�����汾������}
  {.$undef FullDebugMode}
  {.$undef CheckHeapForCorruption}
  {.$define ASMVersion}
  {.$undef EnableMemoryLeakReporting}
  {.$undef UseOutputDebugString}
{$else}
  {���԰汾������}
  {.$define FullDebugMode}
  {.$define EnableMemoryLeakReporting}
  {.$define UseOutputDebugString}
{$endif}

{-------------------- borlndmm.dll ����ѡ�� ---------------------}
{��������ر���borlandmm.dll�ļ����������Ҫ��������ѡ��}

{������borlandmm.dllʱ�뿪����ѡ��}
{.$define borlndmmdll}

{���dll��Delphi����ʹ���뿪����ѡ��}
{.$define dllforide}

{�������dll�ļ�ʱ�뿪����ѡ��}
{.$define debugdll}

{���������벻Ҫ�Ķ�}
{$ifdef borlndmmdll}
  {$define AssumeMultiThreaded}
  {$undef HideExpectedLeaksRegisteredByPointer}
  {$undef RequireDebuggerPresenceForLeakReporting}
  {$undef RequireDebugInfoForLeakReporting}
  {$define DetectMMOperationsAfterUninstall}
  {$undef ManualLeakReportingControl}
  {$undef ShareMM}
  {$undef AttemptToUseSharedMM}
  {$ifdef dllforide}
    {$define NeverUninstall}
    {$define HideMemoryLeakHintMessage}
    {$undef RequireIDEPresenceForLeakReporting}
    {$ifndef debugdll}
      {$undef EnableMemoryLeakReporting}
    {$endif}
  {$else}
    {$define EnableMemoryLeakReporting}
    {$undef NeverUninstall}
    {$undef HideMemoryLeakHintMessage}
    {$define RequireIDEPresenceForLeakReporting}
  {$endif}
  {$ifdef debugdll}
    {$define FullDebugMode}
    {$define RawStackTraces}
    {$undef CatchUseOfFreedInterfaces}
    {$define LogErrorsToFile}
    {$define LogMemoryLeakDetailToFile}
    {$undef ClearLogFileOnStartup}
  {$else}
    {$undef FullDebugMode}
  {$endif}
{$endif}

{��BCB��������ö���������ڡ�Build with Dynamic RTL��ѡ���������£�
CB2006/CB2007���Ա���borlandmm.dll�ļ���׷���ڴ�й¶��}
{------------------------------ רΪBCB���� ----------------------------}

{Ҫ����ΪBCB׼���Ĳ���������Ҫ��"Project Options->Pascal/Delphi Compiler->Defines"
 ������BCB�Ķ��塣����лJiYuan Xieʵ����һ���֣�}

{$ifdef BCB}
  {$ifdef CheckHeapForCorruption}
    {$define PatchBCBTerminate}
  {$else}
    {$ifdef DetectMMOperationsAfterUninstall}
      {$define PatchBCBTerminate}
    {$else}
       {$ifdef EnableMemoryLeakReporting}
         {$define PatchBCBTerminate}
       {$endif}
    {$endif}
  {$endif}

  {$ifdef PatchBCBTerminate}
    {$define CheckCppObjectType}
    {$undef CheckCppObjectTypeEnabled}

    {$ifdef CheckCppObjectType}
      {$define CheckCppObjectTypeEnabled}
    {$endif}

    {���"CheckHeapForCorruption"��"EnableMemoryLeakReporting"��δ��������ر�
     "CheckCppObjectTypeEnabled"}
    {$ifdef CheckHeapForCorruption}
    {$else}
      {$ifdef EnableMemoryLeakReporting}
      {$else}
        {$undef CheckCppObjectTypeEnabled}
      {$endif}
    {$endif}
  {$endif}
{$endif}