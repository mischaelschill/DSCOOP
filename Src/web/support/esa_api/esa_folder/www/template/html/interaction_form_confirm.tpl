<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="../../assets/ico/favicon.ico">
     {include file="optional_styling_css.tpl"/}     
  </head>

  <body>
     {include file="navbar.tpl"/}  

    <div class="container" itemscope itemtype="{$host/}/profile/esa_api.xml">
        <div class="main">
        <div class="form-horizontal well">
          <fieldset>
            <legend>Interaction Submission Confirmation</legend>
            <div class="control-group">
              <label class="control-label" for="textarea" itemprop="description">Description</label>
              <div class="controls">
                {$form.description/}
              </div>
            </div>
            {if isset="$new_status"}  
            <div class="control-group">
              <label class="control-label" for="textarea" itemprop="status">Change status from {$form.report.status.synopsis/} to 
              </label>
              <div class="controls">
                       {foreach from="$status" item="item"} 
                        {if condition="$item.id = $form.selected_status"} 
                          {$item.synopsis/} 
                        {/if} 
                    {/foreach} 
              </div>
            </div>
            {/if}
            {if isset="$private"}  
            <div class="control-group">
              <label class="control-label" for="textarea" itemprop="private">Change Private from {$form.report.confidential/} to 
              </label>
              <div class="controls">
                      {$private/} 
              </div>
            </div>
            {/if}
            <div class="control-group">
              <label class="control-label" for="textarea" itemprop="attachments">Attachments</label>
              <div class="controls">
                {foreach from="attachments" item="item"}
                    {$item.name/} </br>
                {/foreach}
              </div>
            </div>
            <hr>
            <div class="form-actions">
               <form  action="{$host/}/report_detail/{$form.report.number/}/interaction_confirm" method="POST" itemprop="create">
                    <button type="submit" class="btn btn-xs btn-primary">Confirm</button>
                    <input type="hidden" id="confirm" name="confirm" class="form-control" value="{$form.id/}">
               </form> 
              <a class="btn btn-xs btn-primary" href="{$host/}/report_detail/{$form.report.number/}/interaction_form/{$form.id/}" itemprop="update" rel="update">Edit</a> 
            </div>
          </fieldset>
        </div>
   
        </div>
     </div> 
    <!-- Placed at the end of the document so the pages load faster -->
    {include file="optional_enhancement_js.tpl"/}     
  </body>
</html>
