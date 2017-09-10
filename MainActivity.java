package com.oznoz.android.activity.tablet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.app.ActionBar;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.app.SearchManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Configuration;
import android.graphics.Color;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;

import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.SearchView;
import android.widget.TextView;
import com.oznoz.android.FlagsActivity;
import com.oznoz.android.OznozApp;
import com.oznoz.android.R;
import com.oznoz.android.bitmaps.ImageFetcher;
import com.oznoz.android.bitmaps.tablet.ImageCacheTablet;
import com.oznoz.android.dialog.ConfirmBuy;
import com.oznoz.android.dialog.NetworkDialog;
import com.oznoz.android.downloadvideo.NetworkUtils;
import com.oznoz.android.downloadvideo.OznozIntents;
import com.oznoz.android.objects.SessionSearch;
import com.oznoz.android.service.ToolServices;
import com.oznoz.android.tasks.ChangeSync;
import com.oznoz.android.ui.ActionItem;
import com.oznoz.android.ui.BadgeView;
import com.oznoz.android.ui.MenuBarAction;
import com.oznoz.android.utils.OznozAPI;
import com.oznoz.android.fragment.tablet.BaseFragment;
import  com.oznoz.android.fragment.tablet.TabFragment;
public class MainActivity extends FragmentActivity implements SearchView.OnQueryTextListener, SearchView.OnCloseListener{
	public OznozApp instance=null;
	private List<HashMap<String, String>> listLanguage;
	private List<HashMap<String, String>> listAge;
	private TabFragment tabFragment;
	private SearchView mSearchView;
	private Intent intent; 
	private static String languageSelected ="All";
	private static String ageSelected ="All";
	private TextView txtLanguage;
	private TextView txtAge;
	private ImageView iv_age_arrow, iv_language_arrow;
	private MenuBarAction menuBarLanguage;
	private FrameLayout flAge,flLanguage;
	private MenuBarAction menuBarAge;
	private ImageFetcher  mImageThumbs;
	private ImageFetcher  mImageExtra;
	private int countBackPressed = 0;
	private AlertDialog dialogExit;
	private AlertDialog dialogUpgrade;
	protected SharedPreferences oznozData;
	protected SharedPreferences.Editor editor;
	private ProgressDialog proDialog = null;
	protected static boolean tmpExit = false;
	protected static boolean tmpUpgrade = false;
	protected static HashMap<String, String> dataUpgrade = new HashMap<String, String>();
	public static  BadgeView badge;
	private List<HashMap<String, String>> listDownload;
	private BroadcastReceiver myBroadcastReceiver = new BroadcastReceiver() {
        
        @Override
        public void onReceive(Context context, Intent intent) {
        	 if (intent != null ){
        		 String status = intent.getStringExtra("status");
        		 OznozApp.urldownload.clear();
        		 if(status!=null && (status.equals("completed") || status.equals("cancel"))){
        		     if(instance.objMain.getProvider().checkDownloading()==1){
        		        	instance.objMain.getProvider().nextDownloading();
        		     }
        			 List<HashMap<String, String>> listDownload =null;
        	    		if(badge!=null){
        	    			listDownload = instance.objMain.getProvider().getDownloading("1");
        	    			badge.setText(listDownload.size()+"");
        	    			if(listDownload.size()==0){
        	    				badge.setVisibility(View.GONE);
        	    			}
        	    		}
        	        	if(listDownload!=null && listDownload.size()>0){
        	        		for(HashMap<String, String> itemDown :listDownload){
        	        			if(NetworkUtils.checkFileNameFromUrl(itemDown.get("file"))!=null && itemDown.get("status").equals("1") ){
        	        				OznozApp.urldownload.add(itemDown.get("file"));
        			    			Intent downloadIntent = new Intent("com.oznoz.android.downloadvideo.IDownloadService");
        			    			downloadIntent.putExtra(OznozIntents.TYPE, OznozIntents.Types.ADD);
        			    			downloadIntent.putExtra(OznozIntents.URL,itemDown.get("file"));
        						    startService(downloadIntent);
        				    	}
        	        		}
        	        	}
        		 }else if(status!=null && status.toLowerCase().contains("memory")){
        			 showNetworkDialog("Your storage space is full.");
        		 }else if(status!=null && status.toLowerCase().contains("network")){
        			 showNetworkDialog("You can't download in offline mode.");
        		 }
        	 }
        }
    };
    private BroadcastReceiver myUpdateReceiver = new BroadcastReceiver(){
    	 @Override
         public void onReceive(Context context, Intent intent) {
    		 if (intent != null ){
    			if(intent.getBooleanExtra("isOffline", false)==true){
    				if(instance.objMain.getProvider().getDownloading("1").size()>0){
    					showNetworkDialog("You can't download in offline mode.");
    				}
    			}else{
    				SharedPreferences.Editor editorData = null;
    				if(intent.getBooleanExtra("isOffline", true)==false){
    					if(oznozData!=null){
    						if(oznozData.getString("email", "").length()<5){
    							editorData = oznozData.edit();
    							instance.objMain.setAge("0");
    	        				instance.objMain.setLanguage("All");
    	        				editorData = oznozData.edit();
    	        				editorData.clear();
    	        				instance.objMain.getProvider().deleteLogout();
    	        				Intent i = new Intent(getApplicationContext(), LoginActivity.class);
    	        				context.startActivity(i);
    	        				finish();
    						}
    					}
    				}
	        		Bundle getData = intent.getBundleExtra("synceddata");
	        		Bundle version = intent.getBundleExtra("version");
	        		if(getData!=null){
	        			if(getData.getString("customerId").equals("0")){
	        				editorData = oznozData.edit();
	        				editorData.clear();
							instance.objMain.setAge("0");
	        				instance.objMain.setLanguage("All");
	        				instance.objMain.getProvider().deleteLogout();
	        				Intent i = new Intent(getApplicationContext(), LoginActivity.class);
	        				context.startActivity(i);
	        				finish();
	        			}else{
	        				editorData = oznozData.edit();
	            			editorData.putString("subscripiton_expired",getData.getString("subscripiton_expired"));
	            			editorData.putString("subscribed", getData.getString("subscribed"));
	            			editorData.putString("numbercard", getData.getString("numbercard"));
	            			editorData.putString("ccode", getData.getString("ccode"));
	            			editorData.commit();//customerId
	        			}
	        			
	        		}
	        		getData = null;
	        		if(version!=null){
	        			try {
							PackageInfo pInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
							Log.v("version",pInfo.versionName + "=="+version.getString("ver"));
							if(version.getString("ver").trim().equals(pInfo.versionName)==false 
									&& version.getString("status").equals("1")){
								tmpUpgrade = true;
								
								dataUpgrade.put("url", version.getString("url"));
								dataUpgrade.put("message", version.getString("message"));
								dataUpgrade.put("title", version.getString("title"));
								dataUpgrade.put("ver", version.getString("ver"));
								dataUpgrade.put("type", version.getString("type"));
								dataUpgrade.put("status", version.getString("status"));
								
								dialogUpgrade.setTitle(version.getString("title"));
								dialogUpgrade.setMessage(version.getString("message"));
								if(version.getString("type").equals("1")){
									 // 1close 0/Go to Google Play
									 dialogUpgrade.setButton( Dialog.BUTTON_POSITIVE, "Yes", new DialogInterface.OnClickListener() {
									     public void onClick(DialogInterface dialog, int which) {
									    	 dialogUpgrade.dismiss(); 
									     }
									 });
								}else{
									dialogUpgrade.setButton( Dialog.BUTTON_POSITIVE, "Go to Google Play", new DialogInterface.OnClickListener() {
									     public void onClick(DialogInterface dialog, int which) {
									    	 final String appPackageName = getPackageName(); // getPackageName() from Context or Activity object
									    	 try {
									    		 dialogUpgrade.dismiss(); 
									    	     startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appPackageName)));
									    	 } catch (android.content.ActivityNotFoundException anfe) {
									    		 dialogUpgrade.dismiss(); 
									    	     startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://play.google.com/store/apps/details?id=" + appPackageName)));
									    	 }
									    	 
									     }
									 });
								}
								dialogUpgrade.show();
							}
							//pInfo.versionName;
						} catch (NameNotFoundException e) {
							Log.e("NameNotFoundException",e.getMessage());
						}
	        			
	        		}
    			}
    			
        		
    		 }
    		  
    	 }
    };
	@Override
	public void onConfigurationChanged(Configuration  newConfig)
	{
	    super.onConfigurationChanged(newConfig);
	    if(tabFragment!=null){
	    	tabFragment.getFragment();
	    }
	}
	//crash here
	@Override
	protected void onSaveInstanceState(Bundle outState) {
		try{
			super.onSaveInstanceState(outState);
		}catch(Exception ex){
			ex.printStackTrace();
		}
	}

	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
	    super.onRestoreInstanceState(savedInstanceState);
	}

	
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		//uncomment for hide toolbars on top
		// getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
		 instance = (OznozApp)getApplicationContext();
		 if(mImageThumbs==null){
			 mImageThumbs = ImageCacheTablet.getImagesThumbs(MainActivity.this);
		 }
		 if(mImageExtra==null){
			 mImageExtra = ImageCacheTablet.getImagesExtra(MainActivity.this);
		 }
		 
		 oznozData = instance.getSharedPreferences("oznoz_user_data", Context.MODE_PRIVATE);
		 countBackPressed = 0;		 
		 listLanguage= instance.objMain.getProvider().getAllLanguages();
		 listAge=instance.objMain.getProvider().getAllAges();
		 menuBarLanguage = new MenuBarAction(this);
		 menuBarAge = new MenuBarAction(this, MenuBarAction.VERTICAL);
		 ActionBar actionBar = getActionBar();
		 if(actionBar==null){
			getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
			actionBar = getActionBar();
		 }
		 actionBar.setDisplayShowTitleEnabled(false);
		 actionBar.setDisplayShowHomeEnabled(false);
		 actionBar.setDisplayShowCustomEnabled(true);
		 
		 setContentView(R.layout.fragment_tablet);
		 actionBar.setCustomView(R.layout.custom_actionbar);
		 setupMenu();
		 OznozApp.progressLoader = (ProgressBar)findViewById(R.id.progressloader);
		
			
		 FragmentManager fm = getSupportFragmentManager();
		 tabFragment = (TabFragment)fm.findFragmentById(R.id.fragment_tab);
		 tabFragment.getFragment(); 
		 
		 boolean theFirstLogin = oznozData.getBoolean("theFirstLogin", false);
		 if(theFirstLogin){
			 proDialog = new ProgressDialog(MainActivity.this);
			 proDialog.setProgressStyle(android.R.attr.progressBarStyleSmall); 
			 proDialog.setCanceledOnTouchOutside(false);
			 proDialog.setCancelable(false);
			 proDialog.setMessage("Login progress...");
			 proDialog.show();
			ChangeSync synce = new ChangeSync(instance,proDialog);
    		if (synce.getStatus() == AsyncTask.Status.PENDING) {
    			if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.HONEYCOMB){
    				synce.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    			}else{
    				synce.execute();
    			}
    		}    		
		 }
	  // Alert Dialog
		
				
		 dialogExit = new AlertDialog.Builder(this).create();
		 dialogExit.setTitle(getResources().getString(R.string.exit_oznoz_title));
		 dialogExit.setMessage(getResources().getString(R.string.exit_oznoz_msg));
		 dialogExit.setButton( Dialog.BUTTON_POSITIVE, "Yes", new DialogInterface.OnClickListener() {
		       public void onClick(DialogInterface dialog, int which) {
		    	    tmpExit = false;
					Intent exitApp = new Intent(getApplicationContext(), FlagsActivity.class);
					exitApp.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP|Intent.FLAG_ACTIVITY_CLEAR_TOP);
					startActivity(exitApp);
					FlagsActivity.exitHandler.sendEmptyMessage(0);
		       }});

		 dialogExit.setButton( Dialog.BUTTON_NEGATIVE, "No", new DialogInterface.OnClickListener()    {
		      public void onClick(DialogInterface dialog, int which) {
		    	  tmpExit = false;
		    	  dialogExit.dismiss();
		      }});
		 if(tmpExit==true){
			 dialogExit.show();
		 }
		 dialogUpgrade = new AlertDialog.Builder(this).create();
		 dialogUpgrade.setCancelable(false);
		 // close Go to Google Play
		 // 	Setting Dialog Title
		 //dialogUpgrade.setTitle("Alert Dialog");
		 // Setting Dialog Message
		 //dialogUpgrade.setMessage("Welcome to AndroidHive.info");
		 //dialogUpgrade.setButton( Dialog.BUTTON_POSITIVE, "Yes", new DialogInterface.OnClickListener() {
		     //  public void onClick(DialogInterface dialog, int which) {
		    	 
		       //}
		 //});

 
		 
		 
		registerReceiver(myBroadcastReceiver, new IntentFilter("download.completed"));
		registerReceiver(myUpdateReceiver, new IntentFilter("synced.completed"));
	}
	@Override
	public void onStart(){
		super.onStart();
		listDownload=instance.objMain.getProvider().getDownloading("1");
	    if(badge==null){
	    	 badge = new BadgeView(this, findViewById(R.id.imgDownload));
	    	 badge.setBadgePosition(BadgeView.POSITION_TOP_RIGHT);
	    }
		if(listDownload.size()>0){
	    	 badge.setText(listDownload.size()+"");
			 badge.show();
		}else{
			 badge.hide();
		}
		if(tmpUpgrade==true && dataUpgrade.containsKey("title")){
			try {
				PackageInfo pInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
				if(dataUpgrade.get("ver").trim().equals(pInfo.versionName)==false 
						&& dataUpgrade.get("status").equals("1")){
					dialogUpgrade.setTitle(dataUpgrade.get("title"));
					dialogUpgrade.setMessage(dataUpgrade.get("message"));
					if(dataUpgrade.get("type").equals("1")){
						 // 1close 0/Go to Google Play
						 dialogUpgrade.setButton( Dialog.BUTTON_POSITIVE, "Yes", new DialogInterface.OnClickListener() {
						     public void onClick(DialogInterface dialog, int which) {
						    	 dialogUpgrade.dismiss(); 
						     }
						 });
					}else{
						dialogUpgrade.setButton( Dialog.BUTTON_POSITIVE, "Go to Google Play", new DialogInterface.OnClickListener() {
						     public void onClick(DialogInterface dialog, int which) {
						    	 final String appPackageName = getPackageName(); // getPackageName() from Context or Activity object
						    	 try {
						    		 dialogUpgrade.dismiss(); 
						    	     startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appPackageName)));
						    	 } catch (android.content.ActivityNotFoundException anfe) {
						    		 dialogUpgrade.dismiss(); 
						    	     startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://play.google.com/store/apps/details?id=" + appPackageName)));
						    	 }
						    	 
						     }
						 });
					}
					dialogUpgrade.show();
				}
				//pInfo.versionName;
			} catch (NameNotFoundException e) {
				Log.e("NameNotFoundException",e.getMessage());
			}
		}
		
		
		ToolServices.startServiceBackground(this);
	}
	@Override
	protected void onResume(){
		super.onResume();			
	}
	@Override
	protected void onDestroy() {
		
		badge =null;
		if(proDialog!=null && proDialog.isShowing()){
			proDialog.dismiss();
		}
		if(dialogExit!=null && dialogExit.isShowing()){
			dialogExit.dismiss();
		}
		if(dialogUpgrade!=null && dialogUpgrade.isShowing()){
			dialogUpgrade.dismiss();
		}
		
		unregisterReceiver(myBroadcastReceiver);
		unregisterReceiver(myUpdateReceiver);
		super.onDestroy();
	}
	
	private void setupMenu(){
		flAge = (FrameLayout)findViewById(R.id.fl_age);
		flLanguage = (FrameLayout)findViewById(R.id.fl_language);
		txtLanguage = (TextView)findViewById(R.id.txtlanguage);
		txtAge = (TextView)findViewById(R.id.txtage);
		iv_age_arrow = (ImageView)findViewById(R.id.iv_age_arrow);
		iv_language_arrow = (ImageView)findViewById(R.id.iv_language_arrow);
		if(listLanguage.size()>0){
			for (int i = 0; i < listLanguage.size(); i++) {
				if(languageSelected.trim().equalsIgnoreCase(listLanguage.get(i).get("name"))){
					menuBarLanguage.addActionItem(new ActionItem(i, listLanguage.get(i).get("name"), null,true));
					if(languageSelected.trim().equalsIgnoreCase("All")){
		                	txtLanguage.setText("All Languages");
		                	txtLanguage.setTextColor(Color.parseColor("#FFFFFF"));
		                	iv_language_arrow.setImageResource(R.drawable.arrow_menu);
		            }else{
		                	txtLanguage.setText(languageSelected);
		                	txtLanguage.setTextColor(Color.parseColor("#EC008C"));
		                	iv_language_arrow.setImageResource(R.drawable.arrow_menu_selected);
		            }
				}else{
					menuBarLanguage.addActionItem(new ActionItem(i, listLanguage.get(i).get("name"), null,false));
				}
			}
		}
		
		if(listAge.size()>0){
			for (int i = 0; i < listAge.size(); i++) {
				if(ageSelected.trim().equalsIgnoreCase(listAge.get(i).get("name"))){
					menuBarAge.addActionItem(new ActionItem(i, listAge.get(i).get("name"), null,true));
					if(ageSelected.trim().equalsIgnoreCase("All")){
						txtAge.setText("Select Age");
						txtAge.setTextColor(Color.parseColor("#FFFFFF"));
						iv_age_arrow.setImageResource(R.drawable.arrow_menu);
					}else{
						txtAge.setText(ageSelected);
						txtAge.setTextColor(Color.parseColor("#EC008C"));
						iv_age_arrow.setImageResource(R.drawable.arrow_menu_selected);
					}
				}else{
					menuBarAge.addActionItem(new ActionItem(i, listAge.get(i).get("name"), null,false));
				}
			}
		}
		
		menuBarLanguage.setOnActionItemClickListener(new MenuBarAction.OnActionItemClickListener() {			
			@Override
			public void onItemClick(MenuBarAction source, int pos, int actionId) {
				ActionItem actionItem =  menuBarLanguage.getActionSelected();
				actionItem.getView().setBackgroundResource(R.drawable.bgmenu);
				actionItem.setSelected(false);
				actionItem = menuBarLanguage.getActionItem(pos);
				languageSelected = actionItem.getTitle();
				actionItem.setSelected(true);
                actionItem.getView().setBackgroundResource(R.drawable.bgmenuselected);
                if(languageSelected.trim().equalsIgnoreCase("All")){
                	instance.objMain.setLanguage(null);
                	txtLanguage.setText("All Languages");
                	txtLanguage.setTextColor(Color.parseColor("#FFFFFF"));
                	iv_language_arrow.setImageResource(R.drawable.arrow_menu);
                }else{
                	instance.objMain.setLanguage(actionItem.getTitle().toString());
                	txtLanguage.setText(actionItem.getTitle());                	
                	txtLanguage.setTextColor(Color.parseColor("#EC008C"));
                	iv_language_arrow.setImageResource(R.drawable.arrow_menu_selected);
                }
                tabFragment.getFragment();
               
			}
		});

		menuBarAge.setOnActionItemClickListener(new MenuBarAction.OnActionItemClickListener() {			
			@Override
			public void onItemClick(MenuBarAction source, int pos, int actionId) {				
				ActionItem actionItem =  menuBarAge.getActionSelected();
				actionItem.getView().setBackgroundResource(R.drawable.bgmenu);
				actionItem.setSelected(false);
				actionItem = menuBarAge.getActionItem(pos);
				ageSelected = actionItem.getTitle();
				actionItem.setSelected(true);
                actionItem.getView().setBackgroundResource(R.drawable.bgmenuselected);
				if(Integer.valueOf(listAge.get(pos).get("AgeId")) >= 0 ){
						instance.objMain.setAge(listAge.get(pos).get("AgeId"));
				}
				if(ageSelected.trim().equalsIgnoreCase("All")==false){
						txtAge.setText(actionItem.getTitle().toString());
						txtAge.setTextColor(Color.parseColor("#EC008C"));
						iv_age_arrow.setImageResource(R.drawable.arrow_menu_selected);
				}else{
						txtAge.setText("Select Age");
						instance.objMain.setAge(null);
						txtAge.setTextColor(Color.parseColor("#FFFFFF"));
						iv_age_arrow.setImageResource(R.drawable.arrow_menu);
				}
				tabFragment.getFragment();
                
			}
		});
		
		
		if(flLanguage!=null){
			flLanguage.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					menuBarLanguage.show(v);
					
				}
			});
		}
		
		if(flAge!=null){
			flAge.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					menuBarAge.show(v);
					
				}
			});
		}
		
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		   super.onCreateOptionsMenu(menu);
		   getMenuInflater().inflate(R.menu.menu, menu);
		   MenuItem searchItem = menu.findItem(R.id.action_search);
	       mSearchView = (SearchView) searchItem.getActionView();
	       setupSearchView(searchItem);
	       if(getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE){
	    	   SessionSearch sessionSearch = new SessionSearch(instance);
	    	   if(sessionSearch.getDetails().get("words").trim().length()>1){
	    		   mSearchView.setIconified(false);   
	    		   mSearchView.clearFocus();
	    		   mSearchView.setQuery(sessionSearch.getDetails().get("words"), false);
	    	   }
	    	   
	       }
	       return super.onCreateOptionsMenu(menu);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
			
			switch(item.getItemId()) {
				 case R.id.menuitem_logout:
					 if(OznozAPI.isNetworkAvailable(instance)==false){
						 showNetworkDialog("You can't logout in offline mode.");
						 return false;
					 }
					 instance.objMain.setAge("0");
     				 instance.objMain.setLanguage("All");
					 instance.objMain.getProvider().deleteLogout();
					 oznozData = instance.getSharedPreferences("oznoz_user_data", Context.MODE_PRIVATE);
					 editor = oznozData.edit();
					 editor.clear();
					 editor.commit();
					 intent = new Intent(getApplicationContext(), LoginActivity.class);
					 badge =null;
					 
					 startActivity(intent);
					 finish();
					break;
				 case R.id.menuitem_myaccount:								   
					 intent= new Intent(getApplicationContext(), MyaccountActivity.class);
					 startActivity(intent);
					break;
					/*case R.id.menuitem_language:
					 languageMenuSelected = item;
					 break;
				 case R.id.menuitem_age:
					 ageMenuSelected = item;
					 break;
				 case R.id.menuitem_settings:
					 intent= new Intent(getApplicationContext(), SettingsActivity.class);
					 startActivity(intent);
					break;*/	
			}
			return false;
		}		
		@Override
        public void onBackPressed() {
			
			countBackPressed +=1;
			if (mSearchView.isShown()){				
				mSearchView.setQuery("",false);
	        }
			
			ArrayList<String> backstackList = instance.getBackStack();
							
            if(backstackList.size()>1){            	
            	int i=(backstackList.size()-1);             		
            		instance.objMain.setCurrFragment(Integer.valueOf(backstackList.get(i-1)));
            		if(BaseFragment.listFragment!=null){
            			BaseFragment.listFragment.clear();
            		}
            		tabFragment.getFragment();
            		backstackList.remove(i);
            } else {
            	instance.objMain.setCurrFragment(1);
            	if(BaseFragment.listFragment!=null){
        			BaseFragment.listFragment.clear();
        		}
        		tabFragment.getFragment();
        		if(countBackPressed>1){
        			tmpExit = true;
        			dialogExit.show();
        		}
            } 
            
            CountDownTimer cd = new CountDownTimer(1000, 1000) {
				@Override
				public void onTick(long millisUntilFinished) {
				}
				@Override
				public void onFinish() {
					countBackPressed = 0;
				}
			};
			cd.start();
			return;
		}				

		@Override
	    public void onLowMemory() 
        {
	        mImageExtra.clearCache();
	        mImageThumbs.clearCache();
	        Runtime.getRuntime().gc();
	        super.onLowMemory();
	    }
		
		protected boolean isAlwaysExpanded() {
	        return true;
	    }
		private void setupSearchView( MenuItem searchItem) {
	        SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
	        if (searchManager != null) {
	            mSearchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));     
	        }
	        mSearchView.setOnQueryTextListener(this);
	        
	        mSearchView.setOnQueryTextFocusChangeListener(new View.OnFocusChangeListener() {
	            @Override
	            public void onFocusChange(View view, boolean queryTextFocused) {
	            	if(queryTextFocused==true && (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE)==false){
		        		flLanguage.setVisibility(View.GONE);
		        		flAge.setVisibility(View.GONE);
	            	}else{
	            		flLanguage.setVisibility(View.VISIBLE);
		        		flAge.setVisibility(View.VISIBLE);
	            	}
	            }
	        });
	    }
		@Override
		public boolean onQueryTextChange(String arg0) {
			return false;
		}
		@Override
		public boolean onQueryTextSubmit(String arg0) {
			hideSoftKeyboard();
			SessionSearch sessionSearch = new SessionSearch(instance);
			sessionSearch.finalSearch();
			instance.objMain.setSearchText(arg0);
			instance.objMain.setCurrFragment(7);
			tabFragment.getFragment();
			mSearchView.clearFocus();
			if( (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE)==false){
				// for close 2 twice setIconified
				mSearchView.setIconified(true);
				mSearchView.setIconified(true);
			}
			flLanguage.setVisibility(View.VISIBLE);
    		flAge.setVisibility(View.VISIBLE);
			return true;
		}
		@Override
		public boolean onClose() {
			instance.objMain.setSearchText(null);
			flLanguage.setVisibility(View.VISIBLE);
    		flAge.setVisibility(View.VISIBLE);
			return false;
		}
		
		private void hideSoftKeyboard() {
			InputMethodManager inputMethodManager = (InputMethodManager)  this.getSystemService(Context.INPUT_METHOD_SERVICE);
			inputMethodManager.hideSoftInputFromWindow(this.getCurrentFocus().getWindowToken(), 0);
		}
		
		public ImageFetcher getImageFetcherThumbs() {
	        return mImageThumbs;
	    }
		public ImageFetcher getImageFetcherExtra() {
	        return mImageExtra;
	    }
		public void showNetworkDialog(String text){
			try{
	    	 FragmentManager fm = getSupportFragmentManager();
	         NetworkDialog netDialog = new NetworkDialog();
	         netDialog.setText(text);
	         netDialog.show(fm, null);
			}catch(Exception e){
				e.printStackTrace();
			}
	    }
		public void showBuyDialog() {
			try{
		        FragmentManager fm = getSupportFragmentManager();
		        ConfirmBuy buyDialog = new ConfirmBuy();
		        buyDialog.show(fm, null);
			}catch(Exception e){
				e.printStackTrace();
			}
		}
}

